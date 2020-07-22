//=============================================================================
// RPGDamageType.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Damage Types that have custom weapon stat entries for "F3" (such as Lightning Rod, Ultima etc)
class RPGDamageType extends DamageType
    abstract;

var class<Weapon> StatWeapon;

defaultproperties {
}
