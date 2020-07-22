//=============================================================================
// DamTypeAutoGunLaser.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeAutoGunLaser extends VehicleDamageType
    abstract;

defaultproperties
{
     VehicleClass=Class'RPGAutoGun'
     DeathString="%o was served an extra helping of %k's lasers."
     FemaleSuicide="%o fried herself with her own laser blast."
     MaleSuicide="%o fried himself with his own laser blast."
     bDelayedDamage=True
}
