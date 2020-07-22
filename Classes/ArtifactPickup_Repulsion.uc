//=============================================================================
// ArtifactPickup_Repulsion.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Repulsion extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_Repulsion'
    PickupMessage="You got the Repulsion!"
    StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockTankEffectRing'
    DrawScale=0.330000
}
