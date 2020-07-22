//=============================================================================
// EngineerLinkGun.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EngineerLinkGun extends RPGLinkGun
    config(User)
    HideDropDown
    CacheExempt;

var float HealTimeDelay;     // when linking to turrets how long after healing before get damage boost

defaultproperties
{
     HealTimeDelay=0.500000
     FireModeClass(0)=Class'EngineerLinkProjFire'
     FireModeClass(1)=Class'EngineerLinkFire'
}
