//=============================================================================
// RPGExplosive.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGExplosive extends Pawn;

// note a lot of code ripped from the Decoration class. Unfortunately no multiple inheritance

var byte Team;

// If set, the pyrotechnic or explosion when item is damaged.
var()  class<actor> EffectWhenDestroyed;
var() bool bDamageable;
var bool bSplash;

var const int   numLandings;       // Used by engine physics.

var()   int     NumFrags;       // number of fragments to spawn when destroyed
var()   texture FragSkin;       // skin to use for fragments
var()   class<Fragment> FragType;   // type of fragment to use
var     vector FragMomentum;        // momentum to be imparted to frags when destroyed

var VolumeTimer VT;
var float       RadiusDamage;
var float       ExplodingDamage;
var float       MomentumDamage;
var float       CollisionDamage;
var Pawn        PawnOwner;

function SetPawnOwner(Pawn P)
{
    PawnOwner = P;
}

function SetTeamNum(byte T)
{
    Team = T;
}

simulated function int GetTeamNum()
{
    return Team;
}

function bool CanSplash()
{
    if ( (Level.TimeSeconds - SplashTime > 0.25)
        && (Physics == PHYS_Falling)
        && (Abs(Velocity.Z) > 100) )
    {
        SplashTime = Level.TimeSeconds;
        return true;
    }
    return false;
}

function Drop(vector newVel);

function Landed(vector HitNormal)
{
    local rotator NewRot;

    if (Velocity.Z <- 500)
        TakeDamage(((0.0 - Velocity.Z) * Mass) / 20000, Pawn(Owner), HitNormal, HitNormal * 10000, class'Crushed');
    Super.Landed(HitNormal);
    Velocity = vect(0,0,0);
    NewRot = Rotation;
    NewRot.Pitch = 0;
    NewRot.Roll = 0;
    SetRotation(NewRot);
}

function HitWall (vector HitNormal, actor Wall)
{
    Landed(HitNormal);
}

singular function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if(NewVolume.bWaterVolume)
    {
        if(bSplash && !PhysicsVolume.bWaterVolume && Mass <= Buoyancy
            && (Abs(Velocity.Z) < 100 || Mass == 0) && FRand() < 0.05 && !PlayerCanSeeMe())
        {
            bSplash = false;
            SetPhysics(PHYS_None);
        }
    }
    if(PhysicsVolume.bWaterVolume && Buoyancy > Mass)
    {
        if( Buoyancy > 1.1 * Mass )
            Buoyancy = 0.95 * Buoyancy; // waterlog
        else if(Buoyancy > 1.03 * Mass)
            Buoyancy = 0.99 * Buoyancy;
    }
}

function Trigger( actor Other, pawn EventInstigator )
{
    Instigator = EventInstigator;
    TakeDamage(CollisionDamage, Instigator, Location, vect(0, 0, 1) * 900, class'Crushed');
}

simulated function Destroyed()
{
    local int i;
    local Fragment s;
    local float BaseSize;

    if((Level.NetMode != NM_DedicatedServer)
    && !PhysicsVolume.bDestructive
    && NumFrags > 0 && FragType != None)
    {
        // spawn fragments
        BaseSize = 0.8 * sqrt(CollisionRadius * CollisionHeight) / NumFrags;
        for(i = 0; i < numfrags; i++)
        {
            s = Spawn(FragType, Owner,, Location + CollisionRadius * VRand());
            s.CalcVelocity(FragMomentum);
            if (FragSkin != None)
                s.Skins[0] = FragSkin;
            s.SetDrawScale(BaseSize * (0.5 + 0.7 * FRand()));
        }
    }

    Super.Destroyed();
}

//****************************************************************************************************************************

function SetDelayedDamageInstigatorController(Controller C)
{
    DelayedDamageInstigatorController = C;
}

function TakeDamage( int NDamage, Pawn instigatedBy, vector hitlocation, vector momentum, class<DamageType> damageType)
{
    if(!bDamageable || Health < 0)
        return;

    if(damagetype == None)
        DamageType = class'DamageType';

    if(InstigatedBy != None)
        Instigator = InstigatedBy;
    else if((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
        instigatedBy = DelayedDamageInstigatorController.Pawn;

    if(Instigator != None)
        MakeNoise(1.0);

    Health -= NDamage;
    FragMomentum = Momentum;

    if(Health < 0)
    {
        NetUpdateTime = Level.TimeSeconds - 1;
        CheckNearbyExplosives();

        if(EffectWhenDestroyed != None)
            Spawn(EffectWhenDestroyed, Owner,, Location);

        bHidden = true;
        SetCollision(false, false, false);
        VT = Spawn(class'VolumeTimer', Self);       // and set timer for doing the damage
        VT.SetTimer(0.2, false);
    }
}

// Explosives stacked on top, are set off instantly. Sides and below are set off with a slight delay
function CheckNearbyExplosives()
{
    local RPGExplosive Victims;

    if( bHurtEntry )
        return;

    bHurtEntry = true;

    foreach CollidingActors(class'RPGExplosive', Victims, RadiusDamage, Location)
    {
        // Set off top Explosives instantly, side and below are set off with a delay
        // only those very close or above it go straight away
        if((Victims.Location.Z <= Location.Z || IsNearbyExplosive(Victims)) && Victims != self && Victims.Health > 0 && FastTrace(Location,Victims.Location))
        {
            // give it a prod. Do not worry about what team it is on
            GiveExplodingDamage(Victims, ExplodingDamage, RadiusDamage, Location, MomentumDamage, class'DamTypeExploBarrel');
        }
    }

    bHurtEntry = false;
}

function GiveExplodingDamage(Pawn Target, float DamageAmount, float DamageRadius, vector HitLocation, float Momentum, class<DamageType> DamageType )
{
    local float damageScale, dist;
    local vector dir;
    local Vehicle V;
    local Pawn D;
    local bool bScoreThis;

    dir = Target.Location - HitLocation;
    dist = FMax(1, VSize(dir));
    dir = dir / dist;
    damageScale = 1 - FMax(0, (dist - Target.CollisionRadius) / DamageRadius);
    if(PawnOwner == None || PawnOwner.Controller == None)
        Target.SetDelayedDamageInstigatorController(DelayedDamageInstigatorController);

    // see if we have a hehicle, and if it has a driver
    V = Vehicle(Target);
    D = None;
    if(V != None && V.Driver != None && V.Driver.Health > 0)
        D = V.Driver;

    if(Target.Controller != None && PawnOwner != None && PawnOwner.Controller != None && !Target.Controller.SameTeamAs(PawnOwner.Controller))
        bScoreThis = true;
    else
        bScoreThis = false;

    // ok now do the damage
    Target.TakeDamage(damageScale * DamageAmount,PawnOwner,Target.Location - 0.5 * (Target.CollisionHeight + Target.CollisionRadius) * dir, (damageScale * Momentum * dir), DamageType);

    //first see if we killed it
    if(V != None || D != None)
    {   // it was a vehicle. Don't really care if the vehicle is ok, but lets see if we hit the driver as well
        if(PawnOwner != None && D != None && D.Health > 0)
        {
            V.DriverRadiusDamage(DamageAmount, DamageRadius, PawnOwner.Controller, DamageType, Momentum, HitLocation);
        }
    }
}

// delayed explosion for Explosive chain reaction explosions
function TimerPop( VolumeTimer T )
{
    VT.Destroy();
    HurtRadius( ExplodingDamage, RadiusDamage, class'DamTypeExploBarrel', MomentumDamage, Location );
}

/*
 Hurt locally authoritative actors within the radius. But not on same team if a team game
*/
function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local Pawn P;

    if(bHurtEntry)
        return;

    bHurtEntry = true;

    foreach CollidingActors( class 'Pawn', P, DamageRadius, HitLocation )
    {
        if ( P != None && P.Health > 0 && P.Controller != None && PawnOwner != None && PawnOwner.Controller != None && !P.Controller.SameTeamAs(PawnOwner.Controller) && FastTrace(Location,P.Location))
        {
            if( (P != self) && (P.Role == ROLE_Authority) )
            {
                GiveExplodingDamage(P, DamageAmount, RadiusDamage, Location, Momentum, class'DamTypeExploBarrel' );
            }
        }
    }
    bHurtEntry = false;
}

simulated final function bool IsNearbyExplosive(Actor A)
{
    local vector Dir;

    Dir = Location - A.Location;
    if ( abs(Dir.Z) > CollisionHeight*3.67 )
        return false;

    Dir.Z = 0;
    return ( VSize(Dir) <= CollisionRadius*3.25 );
}

function Bump( actor Other )
{
    if ( Mover(Other) != None && Mover(Other).bResetting )
        return;

    if ( VSize(Other.Velocity) > 500 )
    {
        Instigator = PawnOwner;
        if ( PawnOwner != None && PawnOwner.Controller != None )
            SetDelayedDamageInstigatorController( PawnOwner.Controller );
        TakeDamage( VSize(Other.Velocity)*0.03, PawnOwner, Location, vect(0,0,0), class'Crushed');
    }
}

event EncroachedBy(Actor Other)
{
    if ( Mover(Other) != None && Mover(Other).bResetting )
        return;

    Instigator = PawnOwner;
    if ( PawnOwner != None && PawnOwner.Controller != None )
        SetDelayedDamageInstigatorController( PawnOwner.Controller );
    TakeDamage( CollisionDamage, PawnOwner, Location, vect(0,0,0), class'Crushed');
}

function bool EncroachingOn(Actor Other)
{
    if ( Mover(Other) != None && Mover(Other).bResetting )
        return false;

    Instigator = PawnOwner;
    if ( PawnOwner != None && PawnOwner.Controller != None )
        SetDelayedDamageInstigatorController( PawnOwner.Controller );
    TakeDamage( CollisionDamage, PawnOwner, Location, vect(0,0,0), class'Crushed');
    return false;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
    EffectWhenDestroyed=Class'FX_RPGExplodingBarrel'
    bDamageable=True
    RadiusDamage=300.000000
    ExplodingDamage=150.000000
    MomentumDamage=600.000000
    CollisionDamage=100.000000
    bCanBeBaseForPawns=True
    bNoTeamBeacon=True
    Health=25
    ControllerClass=None
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'AS_Decos.ExplodingBarrel'
    bStasis=False
    bOrientOnSlope=True
    Physics=PHYS_Falling
    NetUpdateFrequency=2.000000
    AmbientGlow=48
    bShouldBaseAtStartup=False
    CollisionRadius=22.000000
    CollisionHeight=32.000000
    bBlockPlayers=True
    bUseCylinderCollision=True
    bBlockKarma=True
}
