//=============================================================================
// ProjAugment_Shimmering.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ProjAugment_Shimmering extends RPGProjectileAugment;

function StartEffect()
{
    SetTimer(FRand() * 0.5, false);
}

function StopEffect()
{
    SetTimer(0.0, false);
}

function Timer()
{
    local float damageScale, dist;
    local vector dir;
    local Actor Victims;

    if(!bTimerLoop)
        SetTimer(0.5, true);

    foreach CollidingActors(class'Actor', Victims, Proj.DamageRadius, Proj.Location)
    {
        if(
            Victims != Instigator
            && FluidSurfaceInfo(Victims) == None
            && FastTrace(Proj.Location, Victims.Location)
        )
        {
            if(Pawn(Victims) != None && class'Util'.static.SameTeamC(Pawn(Victims).Controller, InstigatorController))
                continue;

            dir = Victims.Location - Proj.Location;
            dist = FMax(1, VSize(dir));
            dir = dir / dist;
            damageScale = 1 - FMax(0, (dist - Victims.CollisionRadius) / Proj.DamageRadius);
            Victims.TakeDamage
            (
                damageScale * Proj.Damage,
                Proj.Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                vect(0, 0, 0),
                Proj.MyDamageType
            );
            if (Proj.Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
            {
                Vehicle(Victims).DriverRadiusDamage(
                    Proj.Damage * Modifier,
                    Proj.DamageRadius,
                    InstigatorController,
                    Proj.MyDamageType,
                    0,
                    Proj.Location
                );
            }
        }
    }
}

defaultproperties
{
}
