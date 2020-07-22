//=============================================================================
// ArtifactPickup_MonsterSummon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_MonsterSummon extends RPGArtifactPickup;

defaultproperties
{
    DrawScale=0.250000
    InventoryType=Class'Artifact_SummonMonster'
    PickupMessage="You got the Summoning Charm!"
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.MonsterSummon'
}
