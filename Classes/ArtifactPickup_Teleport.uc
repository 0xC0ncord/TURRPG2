//=============================================================================
// ArtifactPickup_Teleport.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Teleport extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_Teleport'
    PickupMessage="You got the Teleporter!"
    PickupSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
    PickupForce="TranslocatorModuleRegeneration"
    DrawType=DT_Mesh
    Mesh=SkeletalMesh'Weapons.TransBeacon'
    DrawScale=2.000000
}
