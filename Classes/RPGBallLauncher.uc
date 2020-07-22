//=============================================================================
// RPGBallLauncher.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBallLauncher extends BallLauncher
    HideDropDown
    CacheExempt;

var Weapon RestoreWeapon; //for Denial 3

simulated function BringUp(optional Weapon PrevWeapon)
{
    if(Role == ROLE_Authority)
        RestoreWeapon = PrevWeapon;

    Super.BringUp(PrevWeapon);
}

defaultproperties
{
}
