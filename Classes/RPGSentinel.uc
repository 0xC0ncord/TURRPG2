//=============================================================================
// RPGSentinel.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGSentinel extends ASVehicle_Sentinel_Floor
    cacheexempt;

simulated event PostBeginPlay()
{
    DefaultWeaponClassName=string(class'Weapon_RPGSentinel');

    super.PostBeginPlay();
}

defaultproperties
{
     DefaultWeaponClassName=""
}
