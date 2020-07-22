//=============================================================================
// DamTypeEnergyWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeEnergyWall extends VehicleDamageType
    abstract;

defaultproperties
{
     VehicleClass=Class'RPGEnergyWall'
     DeathString="%o was SIZZLED by the power of %k's wall!"
     FemaleSuicide="%o was SIZZLED!"
     MaleSuicide="%o was SIZZLED!"
     bKUseOwnDeathVel=True
     bDelayedDamage=True
}
