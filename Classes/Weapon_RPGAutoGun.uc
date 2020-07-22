//=============================================================================
// Weapon_RPGAutoGun.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Weapon_RPGAutoGun extends Weapon_Sentinel
    config(user)
    HideDropDown
    CacheExempt;

defaultproperties
{
     FireModeClass(0)=Class'FM_RPGAutoGun_Fire'
     FireModeClass(1)=Class'FM_RPGAutoGun_Fire'
     ItemName="AutoGun Weapon"
}
