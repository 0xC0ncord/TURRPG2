//=============================================================================
// Artifact_LightningBeam.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_LightningBeam extends ArtifactBase_Beam;

defaultproperties
{
    PickupClass=Class'ArtifactPickup_LightningBeam'
    IconMaterial=Texture'LightningBeamIcon'
    ItemName="Lightning Beam"
    ArtifactID="Beam"
    Description="Fires a bolt of lightning at the desired target."
    HudColor=(R=64,G=200,B=255)
}
