//=============================================================================
// Artifact_ArtificerCharmBeta.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_ArtificerCharmBeta extends ArtifactBase_ArtificerCharm;

defaultproperties
{
    UnloadArtifactClass=class'Artifact_ArtificerUnloadBeta'
    ModifierClass=Class'WeaponModifier_ArtificerBeta'
    ArtifactID="ArtificerCharmBeta"
    IconMaterial=Texture'ArtificerCharmBetaIcon'
    ItemName="Artificer's Charm: Beta"
}
