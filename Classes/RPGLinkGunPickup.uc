//=============================================================================
// RPGLinkGunPickup.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Hack fix for Link Gun so you can link with RPGWeapons that have LinkGun as their ModifiedWeapon
class RPGLinkGunPickup extends LinkGunPickup;

defaultproperties
{
     InventoryType=Class'RPGLinkGun'
}
