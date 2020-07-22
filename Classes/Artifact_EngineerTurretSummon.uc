//=============================================================================
// Artifact_EngineerTurretSummon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EngineerTurretSummon extends ArtifactBase_EngineerSummon
    config(TURRPG2);

defaultproperties
{
    ConstructionType="TURRET"
    IconMaterial=Texture'SummonTurretIcon'
    ItemName="Construct Turret"
    ArtifactID="BuildTurret"
    SelectionTitle="Pick a turret to construct:"
    Description="Constructs a mannable turret of your choice."
}
