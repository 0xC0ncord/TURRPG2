//=============================================================================
// ArtifactPickup_SelfDestruct.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_SelfDestruct extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_SelfDestruct'
    PickupMessage="You got the Self Destruction!"
    StaticMesh=StaticMesh'DespFallencity-SM.C4'
    DrawScale=1.000000
}
