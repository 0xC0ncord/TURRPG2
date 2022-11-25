//=============================================================================
// Artifact_ArtificerCharmGamma.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_ArtificerCharmGamma extends ArtifactBase_ArtificerCharm;

defaultproperties
{
    UnloadArtifactClass=class'Artifact_ArtificerUnloadGamma'
    ModifierClass=Class'WeaponModifier_ArtificerGamma'
    ArtifactID="ArtificerCharmGamma"
    IconMaterial=Texture'ArtificerCharmGammaIcon'
    ItemName="Artificer's Charm: Gamma"
}
