//=============================================================================
// DummyWeapon_SelfDestruct.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Dummy weapon to track kills in the "F3 stats"
class DummyWeapon_SelfDestruct extends Weapon
    HideDropDown
    CacheExempt;

defaultproperties
{
    ItemName="Self Destruction"
}
