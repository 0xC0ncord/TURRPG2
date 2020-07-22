//=============================================================================
// Artifact_EngineerSentinelSummon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EngineerSentinelSummon extends ArtifactBase_EngineerSummon
    config(TURRPG2);

defaultproperties
{
    ConstructionType="SENTINEL"
    IconMaterial=Texture'SummonSentinelIcon'
    ItemName="Construct Sentinel"
    ArtifactID="BuildSentinel"
    SelectionTitle="Pick a sentinel to construct:"
    Description="Constructs an automated sentinel of your choice."
}
