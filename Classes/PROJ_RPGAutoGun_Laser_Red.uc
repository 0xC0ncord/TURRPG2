//=============================================================================
// PROJ_RPGAutoGun_Laser_Red.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class PROJ_RPGAutoGun_Laser_Red extends PROJ_RPGAutoGun_Laser;

simulated function SetupProjectile()
{
    super.SetupProjectile();

    if ( Laser != None )
        Laser.SetRedColor();
}

simulated function SpawnExplodeFX(vector HitLocation, vector HitNormal)
{
    local   FX_PlasmaImpact         FX_Impact;

    if ( EffectIsRelevant(Location, false) )
    {
        FX_Impact = Spawn(class'FX_PlasmaImpact',,, HitLocation + HitNormal * 2, rotator(HitNormal));
        FX_Impact.SetRedColor();
    }
}

defaultproperties
{
}
