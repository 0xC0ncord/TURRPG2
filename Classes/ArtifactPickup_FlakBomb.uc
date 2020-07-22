//=============================================================================
// ArtifactPickup_FlakBomb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_FlakBomb extends RPGArtifactPickup;

defaultproperties {
    InventoryType=Class'Artifact_FlakBomb'
    PickupMessage="You got the Flak Bomb!"
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.megablast'
    Skins(0)=Shader'TURRPG2.Shaders.BombIconOS'
    DrawScale=0.220000
}
