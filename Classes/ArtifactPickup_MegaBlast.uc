//=============================================================================
// ArtifactPickup_MegaBlast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_MegaBlast extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_MegaBlast'
    PickupMessage="You got the Mega Blast!"
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.MegaBlast'
    DrawScale=0.220000
}
