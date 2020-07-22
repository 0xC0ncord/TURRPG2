//=============================================================================
// Artifact_EngineerUtilitySummon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EngineerUtilitySummon extends ArtifactBase_EngineerSummon
    config(TURRPG2);

defaultproperties
{
    ConstructionType="UTILITY"
    IconMaterial=Texture'SummonUtilityIcon'
    ItemName="Construct Utility"
    ArtifactID="BuildUtility"
    SelectionTitle="Pick a utility to construct:"
    Description="Constructs a miscellaneous utility of your choice."
}
