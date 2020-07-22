//=============================================================================
// DamTypeRPGBallTurret.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeRPGBallTurret extends VehicleDamageType
    abstract;

defaultproperties
{
     VehicleClass=Class'RPGBallTurret'
     DeathString="%o was served an extra helping of %k's plasma."
     FemaleSuicide="%o fried herself with her own plasma blast."
     MaleSuicide="%o fried himself with his own plasma blast."
     bDelayedDamage=True
}
