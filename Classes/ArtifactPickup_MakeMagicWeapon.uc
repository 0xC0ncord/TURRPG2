//=============================================================================
// ArtifactPickup_MakeMagicWeapon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_MakeMagicWeapon extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_MakeMagicWeapon'
    PickupMessage="You got the Magic Weapon Maker!"
    PickupSound=Sound'PickupSounds.ShieldPack'
    PickupForce="ShieldPack"
    StaticMesh=StaticMesh'XPickups_rc.UDamagePack'
    bAcceptsProjectors=False
    DrawScale=0.100000
    Skins(0)=Shader'AWGlobal.Shaders.LiquidCoolant'
    AmbientGlow=255
}
