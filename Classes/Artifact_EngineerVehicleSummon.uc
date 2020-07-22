//=============================================================================
// Artifact_EngineerVehicleSummon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EngineerVehicleSummon extends ArtifactBase_EngineerSummon
    config(TURRPG2);

defaultproperties
{
    ConstructionType="VEHICLE"
    IconMaterial=Texture'SummonVehicleIcon'
    ItemName="Construct Vehicle"
    ArtifactID="BuildVehicle"
    SelectionTitle="Pick a vehicle to construct:"
    Description="Constructs a vehicle of your choice."
}
