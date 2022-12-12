//=============================================================================
// Actor_StoredPowerExplosion.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Actor_StoredPowerExplosion extends Actor;

var() int Damage;
var() float DamageRadius;

var float Multiplier;
var Controller InstigatorController;

event PostBeginPlay()
{
    InstigatorController = Instigator.Controller;
    SetTimer(1, false);
}

function InitEffects()
{
    local FX_StoredPowerExplosion FX;

    FX = Spawn(class'FX_StoredPowerExplosion', self,, Location);
    FX.Init(Multiplier);
}

function Timer()
{
    local Actor Victims;
    local vector dir;
    local float dist, damageScale;

    foreach CollidingActors(class'Actor', Victims, DamageRadius * Multiplier)
    {
        if(
            Victims == Self
            || Victims == Instigator
            || Victims.Role < ROLE_Authority
            || FluidSurfaceInfo(Victims) != None
            || (
                Pawn(Victims) != None
                && class'Util'.static.SameTeamP(Instigator, Pawn(Victims))
            )
            || !FastTrace(Victims.Location, Location)
        )
        {
            continue;
        }

        dir = Victims.Location - Location;
        dist = FMax(1, VSize(dir));
        dir = dir / dist;
        damageScale = 1 - FMax(0, (dist - Victims.CollisionRadius) / DamageRadius * Multiplier);
        Victims.TakeDamage
        (
            damageScale * Damage * Multiplier,
            Instigator,
            Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
            (damageScale * -35000 * dir),
            class'DamTypeStoredPowerExplosion'
        );
        if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
            Vehicle(Victims).DriverRadiusDamage(
                Damage * Multiplier,
                DamageRadius * Multiplier,
                InstigatorController,
                class'DamTypeStoredPowerExplosion',
                35000,
                Location
            );
    }
    Destroy();
}

defaultproperties
{
    Damage=80
    DamageRadius=220.0
    bHidden=True
    RemoteRole=ROLE_None
    bSkipActorPropertyReplication=True
    bReplicateMovement=False
}
