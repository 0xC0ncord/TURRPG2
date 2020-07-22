//=============================================================================
// Artifact_MegaBlast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_MegaBlast extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Mega'
    BlastProjectileClass=class'BlastProjectile_Mega'
    AIHealthMin=75
    MaxUses=-1 //infinite

    CostPerSec=150
    HudColor=(G=128)
    ArtifactID="MegaBlast"
    Description="Causes a big badda boom."
    PickupClass=Class'ArtifactPickup_MegaBlast'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.MegaBlast'
    ItemName="Mega Blast"
    bCanBeTossed=False
}
