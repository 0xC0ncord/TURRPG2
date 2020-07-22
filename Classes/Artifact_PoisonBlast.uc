//=============================================================================
// Artifact_PoisonBlast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_PoisonBlast extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Poison'
    BlastProjectileClass=class'BlastProjectile_Poison'
    MaxUses=-1 //infinite

    CostPerSec=150
    HudColor=(R=0)
    ArtifactID="PoisonBlast"
    Description="Poisons nearby enemies."
    PickupClass=Class'ArtifactPickup_PoisonBlast'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.poisonblast'
    ItemName="Poison Blast"
    bCanBeTossed=False
}
