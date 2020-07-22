//=============================================================================
// ArtifactPickup_FreezeBomb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_FreezeBomb extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_FreezeBomb'
    PickupMessage="You got the Freeze Bomb!"
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.FreezeBomb'
    DrawScale=0.220000
}
