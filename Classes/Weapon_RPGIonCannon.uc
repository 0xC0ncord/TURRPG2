//=============================================================================
// Weapon_RPGIonCannon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Weapon_RPGIonCannon extends Weapon_Turret_IonCannon
    config(user)
    HideDropDown
    CacheExempt;

defaultproperties
{
     FireModeClass(0)=Class'FM_RPGIonCannon_Fire'
}
