//=============================================================================
// ArtifactPickup_VehicleBoost.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_VehicleBoost extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_VehicleBoost'
    PickupMessage="You got the Nitro Boost!"
    StaticMesh=StaticMesh'AS_Decos.HellbenderEngine'
    PickupSound=Sound'TURRPG2.Artifacts.NitroPickup'
    DrawScale=0.500000
}
