//=============================================================================
// Artifact_PlusOneModifier.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_PlusOneModifier extends ArtifactBase_PlusXModifier hidedropdown;

defaultproperties
{
    X=1
    ArtifactID="PlusOne"
    Description="Adds 1 level to the weapon's magic if it is at its maximum."
    IconMaterial=Texture'TURRPG2.ArtifactIcons.plus1mod'
    ItemName="Magic Modifier Plus One"
}
