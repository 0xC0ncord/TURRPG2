//=============================================================================
// Artifact_BioBomb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_BioBomb extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Bio'
    BlastProjectileClass=class'BlastProjectile_Bio'

    CostPerSec=75
    HudColor=(R=0)
    ArtifactID="BioBomb"
    Description="Causes a bio glob explosion."
    PickupClass=Class'ArtifactPickup_BioBomb'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.biobomb'
    ItemName="Bio Bomb"
}
