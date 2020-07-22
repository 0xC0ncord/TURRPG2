//=============================================================================
// Artifact_PlusTwoModifier.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_PlusTwoModifier extends ArtifactBase_PlusXModifier hidedropdown;

defaultproperties
{
    X=2
    ArtifactID="PlusTwo"
    Description="Adds 2 levels to the weapon's magic if it is at its maximum."
    IconMaterial=Texture'TURRPG2.ArtifactIcons.plus2mod'
    ItemName="Magic Modifier Plus Two"
}
