//=============================================================================
// WeaponFire_SpreadLinkAlt.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponFire_SpreadLinkAlt extends LinkAltFire;

var int SpreadLevel;

function SetLevel(int NewModifierLevel)
{
    SpreadLevel = NewModifierLevel;
}

function StartSpread()
{
    local int Amount;

    Amount = 1 + SpreadLevel * class'ArtificerAugment_Spread'.default.SpreadLinkAmmoCost;
    Load = Amount;
    AmmoPerFire = Amount;
}

function DoFireEffect()
{
    local vector StartProj, StartTrace, X, Y, Z;
    local rotator R, Aim;
    local vector HitLocation, HitNormal;
    local Actor Other;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X, Y, Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X * ProjSpawnOffset.X;

    if(!Weapon.WeaponCentered())
        StartProj = StartProj + Weapon.Hand * Y * ProjSpawnOffset.Y + Z * ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

    if(Other != None)
        StartProj = HitLocation;

    Aim = AdjustAim(StartProj, AimError);

    X = Vector(Aim);

    SpawnProjectile(StartProj, Rotator(X));

    R.Yaw = 4000;
    SpawnProjectile(StartProj, Rotator(X >> R));

    R.Yaw = -4000;
    SpawnProjectile(StartProj, Rotator(X >> R));

    if(SpreadLevel > 1)
    {
        R.Yaw = 2000;
        SpawnProjectile(StartProj, Rotator(X >> R));

        R.Yaw = -2000;
        SpawnProjectile(StartProj, Rotator(X >> R));
    }
}

defaultproperties
{
    SpreadLevel=1
    AmmoPerFire=4
}
