//=============================================================================
// ArtifactPickup_LightningRod.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_LightningRod extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_LightningRod'
    PickupMessage="You got the Lightning Rod!"
    PickupSound=Sound'PickupSounds.SniperAmmoPickup'
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.Rod'
    DrawScale=0.250000
}
