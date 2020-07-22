//=============================================================================
// ArtifactPickup_LightningBeam.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_LightningBeam extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_LightningBeam'
    PickupMessage="You got the Lightning Beam!"
    PickupSound=Sound'PickupSounds.SniperAmmoPickup'
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.Rod'
    Skins(0)=Shader'LBeam'
    DrawScale=0.250000
    AmbientGlow=128
}
