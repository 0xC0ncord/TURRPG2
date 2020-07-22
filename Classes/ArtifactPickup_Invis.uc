//=============================================================================
// ArtifactPickup_Invis.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Invis extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_Invis'
    PickupMessage="You got the Invisibility!"
    PickupSound=Sound'PickupSounds.SniperAmmoPickup'
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.Invis2M'
    DrawScale=0.50
}
