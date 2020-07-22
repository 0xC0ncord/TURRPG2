//=============================================================================
// Artifact_FlakBomb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_FlakBomb extends ArtifactBase_Blast;

defaultproperties {
    BlastClass=class'Blast_Flak'
    BlastProjectileClass=class'BlastProjectile_Flak'

    CostPerSec=75
    HudColor=(R=255,G=128,B=0)
    ArtifactID="FlakBomb"
    Description="Causes a flak shell explosion."
    PickupClass=Class'ArtifactPickup_FlakBomb'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.FlakBombIcon'
    ItemName="Flak Bomb"
}
