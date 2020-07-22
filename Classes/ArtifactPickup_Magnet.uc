//=============================================================================
// ArtifactPickup_Magnet.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Magnet extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_Magnet'
    PickupMessage="You got the Magnet!"
    StaticMesh=StaticMesh'XGame_rc.BallMesh'
    DrawScale=1.500000
}
