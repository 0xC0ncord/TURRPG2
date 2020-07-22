//=============================================================================
// Artifact_TripleDamage.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_TripleDamage extends Artifact_UDamage;

defaultproperties
{
    UDamageScale=1.500000
    CostPerSec=13
    ArtifactID="Triple"
    Description="Makes you deal three times as much damage as usual."
    PickupClass=Class'ArtifactPickup_TripleDamage'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.Triple'
    ItemName="Triple Damage"
}
