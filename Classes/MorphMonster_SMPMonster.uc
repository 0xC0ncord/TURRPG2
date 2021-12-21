//=============================================================================
// MorphMonster_SMPMonster.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_SMPMonster extends MorphMonster;

var()   float   InvalidityMomentumSize;

var()  array<class<DamageType> >    ReducedDamTypes;
var()  float    ReducedDamPct;
var()  array<class<DamageType> >    WeakDamTypes;
var()  float    WeakDamPct;
var()   string  MonsterName;
var()  bool bReduceDamPlayerNum; //ReduceDamage by Players Number
var()  bool bNoTelefrag; //dont get telefragged

var() bool bNoCrushVehicle;

event EncroachedBy( actor Other )
{
    local float Speed;
    local vector Dir,Momentum;

    if ( xPawn(Other) != None && bNoTelefrag)
        return;
    if(bNoCrushVehicle && Vehicle(Other)!=none)
    {
        Speed=VSize(Vehicle(Other).Velocity);
        Dir=Normal(Vehicle(Other).Velocity);
//      log("dot=" $ Dir dot Normal(Location-Other.Location));

        if(Dir dot Normal(Location-Other.Location)>0)
        {
            Dir=-Dir;
            Momentum=Dir*Speed*Mass*0.1;
            Vehicle(Other).KAddImpulse(Momentum, Other.location);
        }
    }

    super.EncroachedBy(Other);
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    Mass=default.Mass*(CollisionRadius/default.CollisionRadius);

    if(PhysicsVolume.bWaterVolume)
        SetPhysics(PHYS_Swimming);
    if(Texture(Skins[0])!=none)
        Texture(Skins[0]).LODSet=LODSET_PlayerSkin;

}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                        vector momentum, class<DamageType> damageType)
{
    local int i;
    local float DamageProb;

    if(InvalidityMomentumSize>VSize(momentum))
        momentum=vect(0,0,0);

    for(i=0;i<ReducedDamTypes.length;i++)
        if(damageType==ReducedDamTypes[i])
            Damage*=ReducedDamPct;

    for(i=0;i<WeakDamTypes.length;i++)
        if(damageType==WeakDamTypes[i])
            Damage*=WeakDamPct;


    if(Damage>0)
    {
        if(bReduceDamPlayerNum)
        {
            DamageProb=float(Damage)/(Level.Game.NumPlayers+Level.Game.NumBots);
            if(DamageProb<1 && Frand()<DamageProb)
                Damage=1;
            else
                Damage=DamageProb;

        }
    }

    if(bNoCrushVehicle && class<DamTypeRoadkill>(damageType)!=none && Damage>10)
        Damage=10;
    super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

function RosterEntry GetPlacedRoster()
{
    return none;
}
simulated function SpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return;

    Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );

    if( Giblet == None )
        return;

    Giblet.SetDrawScale(Giblet.DrawScale * (CollisionRadius+CollisionHeight)/69); // 69 = 25 + 44
    GibPerterbation *= 32768.0;
    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * 512.0;
}

defaultproperties
{
     InvalidityMomentumSize=1500.000000
     ReducedDamPct=0.500000
     WeakDamPct=2.000000
     MonsterName="Monster"
     bNoDefaultInventory=True
}
