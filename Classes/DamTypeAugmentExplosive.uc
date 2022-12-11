//=============================================================================
// DamTypeAugmentExplosive.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeAugmentExplosive extends WeaponDamageType
    abstract;

defaultproperties
{
     WeaponClass=Class'DummyWeapon_AugmentExplosive'
     DeathString="%o got too close to %k's explosion."
     FemaleSuicide="%o blew herself up."
     MaleSuicide="%o blew himself up."
}

