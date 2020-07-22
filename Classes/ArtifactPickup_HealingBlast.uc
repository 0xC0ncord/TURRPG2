//=============================================================================
// ArtifactPickup_HealingBlast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_HealingBlast extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_HealingBlast'
    PickupMessage="You got the Healing Bomb!"
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.HealingBomb'
    DrawScale=0.220000
}
