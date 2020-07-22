//=============================================================================
// Artifact_ShieldBlast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_ShieldBlast extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Shield'
    BlastProjectileClass=class'BlastProjectile_Shield'
    bFriendly=True
    MaxUses=0 //infinite

    CostPerSec=25
    Cooldown=30
    HudColor=(B=0,G=255,R=255)
    ActivateSound=Sound'ShieldBlastFire'
    ArtifactID="ShieldBlast"
    Description="Boosts shields of nearby teammates."
    IconMaterial=Texture'ShieldBlastIcon'
    ItemName="Shield Blast"
    bCanBeTossed=False
}
