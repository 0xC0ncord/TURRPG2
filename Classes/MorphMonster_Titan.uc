//=============================================================================
// MorphMonster_Titan.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Titan extends MorphMonster_SMPMonster;

var name DeathAnim[3];

var()   int     SlapDamage,PunchDamage;
var     bool                bStomped,bThrowed;
var     int                 ThrowCount;


var() name StompEvent;
var() name StepEvent;
var() sound Step;
var() sound StompSound;
var() sound slap;
var() sound swing;
var() sound throw;

var() float ProjectileSpeed,ProjectileMaxSpeed;

function PlayVictory()
{
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlaySound(sound'chestB2Ti',SLOT_Interact);
    SetAnimAction('TChest');
}

function RangedAttack(Actor A)
{
    local float decision;
    local bool bDidSomething;

    if(Role<Role_Authority)
        return;
//  A=class'Util'.static.GetClosestPawn(Controller);
//  Controller.Enemy=Pawn(A);

    if ( bShotAnim )
        return;

    decision = FRand();

    if ( A!=None && VSize(A.Location - Location) < MeleeRange*CollisionRadius/default.CollisionRadius + CollisionRadius + A.CollisionRadius )
    {
        if ( decision < 0.6 )
        {
            SetAnimAction('TSlap001');
            PlaySound(sound'Punch1Ti', SLOT_Interact);
            PlaySound(sound'Punch1Ti', SLOT_Misc);

        }
        else
        {
            SetAnimAction('TPunc001');
            PlaySound(swing, SLOT_Interact);
            PlaySound(swing, SLOT_Misc);
        }
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bStomped=false;
        bDidSomething=True;
    }
    else if(VSize(Acceleration)~=0f)
    {
        SetAnimAction('TThro001');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        PlaySound(throw, SLOT_Interact);
        bDidSomething=True;
    }
    bShotAnim=bDidSomething;
}

function ProcessAttack(byte Mode)
{
    if(Mode==0)
        RangedAttack(Controller.Target);
    if(Mode==1)
    {
        if(bShotAnim)
            return;
        bShotAnim=True;
        SetAnimAction('TStom001');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        PlaySound(StompSound, SLOT_Interact);
        bStomped=true;
        bThrowed=false;
    }
}

singular event BaseChange()
{
    local float decorMass;

    if ( bInterpolating )
        return;
    if ( (base == None) && (Physics == PHYS_None) )
        SetPhysics(PHYS_Falling);
    // Pawns can only set base to non-pawns, or pawns which specifically allow it.
    // Otherwise we do some damage and jump off.
    else if ( Pawn(Base) != None )
    {
        if ( !Pawn(Base).bCanBeBaseForPawns )
        {
        Base.TakeDamage( 50000, Self,Location,0.5 * Velocity , class'Crushed');
        JumpOffPawn();
        SetPhysics(PHYS_Falling);
        }
    }
    else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
    {
        decorMass = FMax(Decoration(Base).Mass, 1);
        Base.TakeDamage((-2* Mass/decorMass * Velocity.Z*0.25f), Self, Location, 0.5 * Velocity, class'Crushed');
    }
}
function Landed(vector HitNormal)
{
    local pawn Thrown;
    if(Velocity.Z<-10)
        foreach CollidingActors( class 'Pawn', Thrown,Mass)
            ThrowOther(Thrown,Mass/12+(-0.5*Velocity.Z));
    super.Landed(HitNormal);
}

function PunchDamageTarget()
{
    if(Controller==none || Controller.Target==none) return;
    if (MeleeDamageTarget(PunchDamage, (70000.0 * Normal(Controller.Target.Location - Location))) )
    {
        PlaySound(Slap, SLOT_Interact);
        PlaySound(Slap, SLOT_Misc);
    }
}
function SlapDamageTarget()
{
    local vector X,Y,Z;
    if(Controller==none || Controller.Target==none) return;
    GetAxes(Rotation,X,Y,Z);

    if ( MeleeDamageTarget(SlapDamage, (70000.0 * ( Y + vect(0,0,1)))) )
    {
        PlaySound(Slap, SLOT_Interact);
        PlaySound(Slap, SLOT_Misc);
    }
}

function Stomp()
{
    local pawn Thrown;

    TriggerEvent(StompEvent,Self, Instigator);
    Mass=default.Mass*(CollisionRadius/default.CollisionRadius);
    //throw all nearby creatures, and play sound
    foreach CollidingActors( class 'Pawn', Thrown,Mass)
        ThrowOther(Thrown,Mass*0.25f);
    PlaySound(Step, SLOT_Interact, 24);
    bStomped=true;
}

function FootStep()
{
    local pawn Thrown;

    TriggerEvent(StepEvent,Self, Instigator);
    //throw all nearby creatures, and play sound
    foreach CollidingActors( class 'Pawn', Thrown,Mass*0.5)
        ThrowOther(Thrown,Mass/12);
    PlaySound(Step, SLOT_Interact, 24);
}

function ThrowOther(Pawn Other,int Power)
{
    local float dist, shake;
    local vector Momentum;

    if(Other.Controller!=None && Controller!=None && Controller.SameTeamAs(Other.Controller))
        return;

    if ( Other.mass >= Mass )
        return;

    if (xPawn(Other)==none)
    {
        if ( Power<400 || (Other.Physics != PHYS_Walking) )
            return;
        dist = VSize(Location - Other.Location);
        if (dist > Mass)
            return;
    }
    else
    {

        dist = VSize(Location - Other.Location);
        shake = 0.4*FMax(500, Mass - dist);
        shake=FMin(2000,shake);
        if ( dist > Mass )
            return;
        if(Other.Controller!=none)
            Other.Controller.ShakeView( vect(0.0,0.02,0.0)*shake, vect(0,1000,0),0.003*shake, vect(0.02,0.02,0.02)*shake, vect(1000,1000,1000),0.003*shake);

        if ( Other.Physics != PHYS_Walking )
            return;
    }

    Momentum = 100 * Vrand();
    Momentum.Z = FClamp(0,Power,Power - ( 0.4 * dist + Max(10,Other.Mass)*10));
    Other.AddVelocity(Momentum);
}

function PlayDirectionalHit(Vector HitLoc)
{

}
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    AmbientSound = None;
    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;
    LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetPhysics(PHYS_Falling);

    if ( (DamageType == class'DamTypeSniperHeadShot')
        || ((HitLoc.Z > Location.Z + 0.75 * CollisionHeight) && (FRand() > 0.5)
            && (DamageType != class'DamTypeAssaultBullet') && (DamageType != class'DamTypeMinigunBullet') && (DamageType != class'DamTypeFlakChunk')) )
    {
        PlayAnim('TDeat003',1,0.05);
        CreateGib('head',DamageType,Rotation);
        return;
    }
    if ( Velocity.Z > 300 )
    {
        if ( FRand() < 0.5 )
            PlayAnim('TDeat001',1.2,0.05);
        else
            PlayAnim('TDeat002',1.2,0.05);
        return;
    }
    PlayAnim(DeathAnim[Rand(3)],1.2,0.05);
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 1.2*CollisionRadius * X + 0.4 * CollisionHeight * Z;
}

function SpawnRock()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local Projectile   Proj;

    if(Role<Role_Authority)
        return;

    GetAxes(Rotation,X,Y,Z);
    FireStart = Location + 1.2*CollisionRadius * X + 0.4 * CollisionHeight * Z;
    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }

    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    if (FRand() < 0.4)
    {
        Proj=Spawn(class'MorphMonster_TitanBoulder',,,FireStart,FireRotation);
        if(Proj!=none)
        {
            Proj.SetPhysics(PHYS_Projectile);
            Proj.setDrawScale(Proj.DrawScale*DrawScale/default.DrawScale);
            Proj.SetCollisionSize(Proj.CollisionRadius*DrawScale/default.DrawScale,Proj.CollisionHeight*DrawScale/default.DrawScale);
            Proj.Velocity = (ProjectileSpeed+Rand(ProjectileMaxSpeed-ProjectileSpeed)) *vector(Proj.Rotation)*DrawScale/default.DrawScale;
        }
        return;
    }

    Proj=Spawn(class'MorphMonster_TitanBigRock',,,FireStart,FireRotation);
    if(Proj!=none)
    {
        Proj.SetPhysics(PHYS_Projectile);
        Proj.setDrawScale(Proj.DrawScale*DrawScale/default.DrawScale);
        Proj.SetCollisionSize(Proj.CollisionRadius*DrawScale/default.DrawScale,Proj.CollisionHeight*DrawScale/default.DrawScale);
        Proj.Velocity = (ProjectileSpeed+Rand(ProjectileMaxSpeed-ProjectileSpeed)) *vector(Proj.Rotation)*DrawScale/default.DrawScale;
    }
    FireStart=Location + 1.2*CollisionRadius * X -40*Y+ 0.4 * CollisionHeight * Z;
    Proj=Spawn(class'MorphMonster_TitanBigRock',,,FireStart,FireRotation);
    if(Proj!=none)
    {
        Proj.SetPhysics(PHYS_Projectile);
        Proj.setDrawScale(Proj.DrawScale*DrawScale/default.DrawScale);
        Proj.SetCollisionSize(Proj.CollisionRadius*DrawScale/default.DrawScale,Proj.CollisionHeight*DrawScale/default.DrawScale);
        Proj.Velocity = (ProjectileSpeed+Rand(ProjectileMaxSpeed-ProjectileSpeed)) *vector(Proj.Rotation)*DrawScale/default.DrawScale;
    }
    bStomped=false;
    ThrowCount++;
    if(ThrowCount>=2)
    {
        bThrowed=true;
        ThrowCount=0;
    }
}

State Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;
simulated function ProcessHitFX(){}
}

simulated function PlayFlying( bool bIsMoving )
{
    PlayInAir();
}
simulated function PlayWaiting()
{
    LoopAnim('TBrea001',,0.1);
}
simulated function PlayWalking()
{
    LoopAnim('TWalk001', 1,0.1, 0.8);
}
simulated function PlayRunning( byte MovementDir )
{
    LoopAnim('TWalk001', -1.0/GroundSpeed,0.1, 0.8);
}
simulated function PlayInAir()
{
    TweenAnim('TBrea001', 0.1);
}
simulated function PlaySwimming()
{
    PlayWalking();
}

defaultproperties
{
     TauntAnimNames(1)="Fighter"
     TauntAnimNames(2)="Fist"
     TauntAnimNames(3)="Sniff"
     TauntAnimNames(4)="Shuffle"
     TauntAnims(1)="TFigh001"
     TauntAnims(2)="TFist"
     TauntAnims(3)="TSnif001"
     TauntAnims(4)="TShuffle"
     FireAnims(0)="TSlap001"
     FireAnims(1)="TPunc001"
     FireAnims(2)="TThro001"
     FireAnims(3)="TStom001"
     DeathAnim(0)="TDeat001"
     DeathAnim(1)="TDeat002"
     DeathAnim(2)="TDeat003"
     SlapDamage=85
     PunchDamage=80
     StompEvent="TitanStep"
     StepEvent="TitanStep"
     Step=Sound'satoreMonsterPackSound.Titan.step1t'
     StompSound=Sound'satoreMonsterPackSound.Titan.stomp4t'
     Slap=Sound'satoreMonsterPackSound.Titan.slaphit1Ti'
     swing=Sound'satoreMonsterPackSound.Titan.Swing1t'
     Throw=Sound'satoreMonsterPackSound.Titan.Throw1t'
     ProjectileSpeed=900.000000
     ProjectileMaxSpeed=1000.000000
     InvalidityMomentumSize=100000.000000
     MonsterName="Titan"
     bNoTeleFrag=True
     bNoCrushVehicle=True
     bCanDodge=False
     bBoss=True
     HitSound(0)=Sound'satoreMonsterPackSound.Titan.injur1t'
     HitSound(1)=Sound'satoreMonsterPackSound.Titan.injur1t'
     HitSound(2)=Sound'satoreMonsterPackSound.Titan.injur2t'
     HitSound(3)=Sound'satoreMonsterPackSound.Titan.injur2t'
     DeathSound(0)=Sound'satoreMonsterPackSound.Titan.death1t'
     DeathSound(1)=Sound'satoreMonsterPackSound.Titan.death1t'
     ScoringValue=16
     bCanSwim=False
     MeleeRange=150.000000
     GroundSpeed=300.000000
     AccelRate=1000.000000
     JumpZ=0.000000
     Health=900
     MovementAnims(0)="TWalk001"
     MovementAnims(1)="TWalk001"
     MovementAnims(2)="TWalk001"
     MovementAnims(3)="TWalk001"
     TurnLeftAnim="TWalk001"
     TurnRightAnim="TWalk001"
     WalkAnims(0)="TWalk001"
     WalkAnims(1)="TWalk001"
     WalkAnims(2)="TWalk001"
     WalkAnims(3)="TWalk001"
     AirAnims(0)="TBrea001"
     AirAnims(1)="TBrea001"
     AirAnims(2)="TBrea001"
     AirAnims(3)="TBrea001"
     TakeoffAnims(0)="TBrea001"
     TakeoffAnims(1)="TBrea001"
     TakeoffAnims(2)="TBrea001"
     TakeoffAnims(3)="TBrea001"
     LandAnims(0)="TBrea001"
     LandAnims(1)="TBrea001"
     LandAnims(2)="TBrea001"
     LandAnims(3)="TBrea001"
     DodgeAnims(0)="TBrea001"
     DodgeAnims(1)="TBrea001"
     DodgeAnims(2)="TBrea001"
     DodgeAnims(3)="TBrea001"
     AirStillAnim="TBrea001"
     TakeoffStillAnim="TBrea001"
     IdleCrouchAnim="TSit"
     IdleWeaponAnim="TBrea001"
     IdleRestAnim="TBrea001"
     AmbientSound=Sound'satoreMonsterPackSound.Titan.amb1Ti'
     Mesh=VertMesh'satoreMonsterPackMeshes.Titan1'
     Skins(0)=Texture'satoreMonsterPackTexture.Skins.Jtitan1'
     Skins(1)=Texture'satoreMonsterPackTexture.Skins.Jtitan1'
     DrawScale=0.500000
     CollisionRadius=55.000000
     CollisionHeight=57.500000
     Mass=1000.000000
     RotationRate=(Yaw=60000)
}
