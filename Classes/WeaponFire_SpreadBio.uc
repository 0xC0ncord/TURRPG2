//=============================================================================
// WeaponFire_SpreadBio.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponFire_SpreadBio extends BioFire;

var int SpreadLevel;

function SetLevel(int NewModifierLevel)
{
    SpreadLevel = NewModifierLevel;
}

function StartSpread()
{
    local int Amount;

    Amount = 1 + SpreadLevel * class'ArtificerAugment_Spread'.default.SpreadBioAmmoCost;
    Load = Amount;
    AmmoPerFire = Amount;
}

function DoFireEffect()
{
    local vector StartProj, StartTrace, X, Y, Z;
    local rotator R, Aim;
    local vector HitLocation, HitNormal;
    local Actor Other;
    local int NumToFire, i;

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

    if(SpreadLevel == 1)
        NumToFire = 3;
    else
        NumToFire = 5;
    for(i = 0; i < NumToFire; i++)
    {
        R.Yaw = -2000 + (i * 2000) + (Rand(1500) - 750);
        R.Pitch = Rand(2000) - 100;
        SpawnProjectile(StartProj, Rotator(X >> R));
    }
}

defaultproperties
{
    SpreadLevel=1
    AmmoPerFire=4
}

