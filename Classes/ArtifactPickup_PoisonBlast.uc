//=============================================================================
// ArtifactPickup_PoisonBlast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_PoisonBlast extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_PoisonBlast'
    PickupMessage="You got the Poison Blast!"
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.PoisonBlast'
    DrawScale=0.220000
}
