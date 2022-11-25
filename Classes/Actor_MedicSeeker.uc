//=============================================================================
// Actor_MedicSeeker.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Actor_MedicSeeker extends Effects;

var enum ESeekerState
{
    SS_None,
    SS_Healing,
    SS_Attacking,
} SeekerState;
var Emitter FX;
var float ToDestVelocity;
var float Alpha;

var Pawn Target;
var int Amount;
var Pawn Causer;
var bool bAttackingOrigin;
var float StartPursueTime;
var vector LastTargetLocation;
var Ability_LoadedMedic LoadedMedic;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Target, bAttackingOrigin;
}

simulated function PostBeginPlay()
{
    ToDestVelocity = 9600 + 200f * FRand();
    Alpha = 0;

    if(Level.NetMode != NM_DedicatedServer)
        FX = Spawn(class'FX_MedicSeeker', self,, Location);
}

simulated function PostNetBeginPlay()
{
    if(bAttackingOrigin)
        StartPursueTime = Level.TimeSeconds + 0.5;
}

simulated function Destroyed()
{
    if(FX != None)
        FX.Kill();
}

function ServerReachedDest()
{
    local Effect_MedicSeekerHeal Heal;

    if(SeekerState == SS_None || Target == None || Target.Health <= 0)
        return;

    if(SeekerState == SS_Healing && Target.Health < Target.HealthMax + GetMaxHealthBonus())
    {
        if(PlayerController(Target.Controller) != None)
            PlayerController(Target.Controller).ClientFlash(0.80, vect(600, 0, 300));

        Heal = Effect_MedicSeekerHeal(class'Effect_MedicSeekerHeal'.static.Create(Target, Causer.Controller,, GetMaxHealthBonus()));
        if(Heal != None)
        {
            Heal.HealAmount = Amount;
            Heal.Start();
        }
    }
    else if(SeekerState == SS_Attacking && Target.Health > 0)
    {
        Target.TakeDamage(Amount, Causer, Target.Location, vect(0, 0, 0), class'DamTypeMedicIncantation');
        PlaySound(sound'PRVFire01', SLOT_Misc, 0.2,,, 1.9 + FRand() * 0.2);
    }
}

simulated function Tick(float dt)
{
    local vector ToDest, V;

    // in case target dies, let's not go flying
    // off the map
    if(Target != None)
        LastTargetLocation = Target.Location;

    if(Alpha < 1.0)
        Alpha = FMin(1.0, Alpha + dt * 0.8);

    if(StartPursueTime <= Level.TimeSeconds)
    {
        ToDest = LastTargetLocation - Location;
        if(VSize(ToDest) < 20)
        {
            ServerReachedDest();
            Destroy();
            return;
        }
    }
    else
        ToDest = vector(Rotation);

    V = (Velocity * (1.0 - Alpha)) + (ToDestVelocity * Normal(ToDest) * Alpha) + (VRand() * 40);

    if(VSize(V) > 4000 && !bAttackingOrigin)
        V = 4000 * Normal(V);

    if(VSize(Velocity) > ToDestVelocity)
        Velocity = ToDestVelocity * Normal(Velocity);

    SetLocation(Location + (V * dt * FClamp(Abs(StartPursueTime - Level.TimeSeconds), 0.0, 1.0)));
}

final function int GetMaxHealthBonus()
{
    if(LoadedMedic != None)
        return LoadedMedic.GetHealMax();
    return 50;
}

simulated event FellOutOfWorld(eKillZType KillType);

defaultproperties
{
    bHidden=True
    bAcceptsProjectors=False
    bAlwaysRelevant=True
    bReplicateMovement=False
    Physics=PHYS_Projectile
    RemoteRole=ROLE_SimulatedProxy
    LifeSpan=10.000000
    CollisionRadius=40.000000
    CollisionHeight=40.000000
    bIgnoreOutOfWorld=True
    bFixedRotationDir=True
}
