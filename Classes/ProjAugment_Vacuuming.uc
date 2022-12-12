//=============================================================================
// ProjAugment_Vacuuming.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ProjAugment_Vacuuming extends RPGProjectileAugment;

function Explode()
{
    local float vacuumScale, dist;
    local vector dir;
    local Actor Victims;

    foreach CollidingActors(class'Actor', Victims, Proj.DamageRadius * Modifier, Proj.Location)
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
            dir = dir * dist;
            vacuumScale = 1 - FMax(0, (dist - Victims.CollisionRadius) / Proj.DamageRadius * Modifier);
            Victims.TakeDamage
            (
                0,
                Proj.Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                -3 * (vacuumScale * dir),
                Proj.MyDamageType
            );
        }
    }
}

defaultproperties
{
}
