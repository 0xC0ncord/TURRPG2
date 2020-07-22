//=============================================================================
// Artifact_EngineerBuildingSummon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EngineerBuildingSummon extends ArtifactBase_EngineerSummon
    config(TURRPG2);

defaultproperties
{
    ConstructionType="BUILDING"
    IconMaterial=Texture'SummonBuildingIcon'
    ItemName="Construct Building"
    ArtifactID="BuildBuilding"
    SelectionTitle="Pick a building to construct:"
    Description="Constructs a building of your choice."
}
