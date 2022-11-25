//=============================================================================
// Artifact_ArtificerCharmAlpha.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_ArtificerCharmAlpha extends ArtifactBase_ArtificerCharm;

defaultproperties
{
    UnloadArtifactClass=class'Artifact_ArtificerUnloadAlpha'
    ModifierClass=Class'WeaponModifier_ArtificerAlpha'
    ArtifactID="ArtificerCharmAlpha"
    IconMaterial=Texture'ArtificerCharmAlphaIcon'
    ItemName="Artificer's Charm: Alpha"
}
