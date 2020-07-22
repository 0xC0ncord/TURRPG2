//=============================================================================
// ArtifactPickup_Decoy.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Decoy extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_Decoy'
    PickupMessage="You got the Decoy!"
    StaticMesh=StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM'
    DrawScale=0.166667
}
