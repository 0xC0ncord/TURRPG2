//=============================================================================
// FX_RPGIonPlasmaTank_BeamFire.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_RPGIonPlasmaTank_BeamFire extends ONSHoverTank_IonPlasma_BeamFire;

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;
    local Pawn P;
    local bool bSameTeam;

    if( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != instigator) && (Victims != self) && (Victims.Role == ROLE_Authority) && (FluidSurfaceInfo(Victims) == None) && FastTrace(Location,Victims.Location))
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

            bSameTeam = false;
            P = Pawn(Victims);
            if (P != None && P.Controller != None && P.Health > 0 && Instigator != None && P.Controller.SameTeamAs(Instigator.Controller))
                bSameTeam = true;
            if (!bSameTeam)
            {
                Victims.TakeDamage
                (
                    damageScale * DamageAmount,
                    Instigator,
                    Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                    (damageScale * Momentum * dir),
                    DamageType
                );
                if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                    Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
            }
        }
    }
    bHurtEntry = false;
}

defaultproperties
{
     MomentumTransfer=50000.000000
}
