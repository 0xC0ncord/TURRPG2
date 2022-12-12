//=============================================================================
// DamTypeStoredPowerExplosion.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeStoredPowerExplosion extends WeaponDamageType
    abstract;

defaultproperties
{
     WeaponClass=Class'DummyWeapon_AugmentStoredPower'
     DeathString="%o got too close to %k's stored power explosion."
     FemaleSuicide="%o blew herself up."
     MaleSuicide="%o blew himself up."
}
