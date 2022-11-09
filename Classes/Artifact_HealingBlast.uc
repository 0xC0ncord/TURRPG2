//=============================================================================
// Artifact_HealingBlast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_HealingBlast extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Heal'
    BlastProjectileClass=class'BlastProjectile_Heal'
    bFriendly=True
    MaxUses=0 //infinite

    CostPerSec=0
    Cooldown=60
    HudColor=(B=255,G=0,R=0)
    ArtifactID="HealingBlast"
    Description="Heals nearby teammates."
    PickupClass=Class'ArtifactPickup_HealingBlast'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.HealingBomb'
    ItemName="Healing Blast"
    bCanBeTossed=False
}
