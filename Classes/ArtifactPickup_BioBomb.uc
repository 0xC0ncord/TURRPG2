//=============================================================================
// ArtifactPickup_BioBomb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_BioBomb extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_BioBomb'
    PickupMessage="You got the Bio Bomb!"
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.BioBomb'
    DrawScale=0.220000
}
