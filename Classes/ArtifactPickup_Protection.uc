//=============================================================================
// ArtifactPickup_Protection.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Protection extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_Protection'
    PickupMessage="You got the Protection!"
    PickupSound=Sound'PickupSounds.ShieldPack'
    PickupForce="ShieldPack"
    StaticMesh=StaticMesh'Editor.TexPropSphere'
    bAcceptsProjectors=False
    DrawScale=0.075000
    Skins(0)=Shader'TURRPG2.ArtifactPickupSkins.GlobeShader'
    AmbientGlow=255
}
