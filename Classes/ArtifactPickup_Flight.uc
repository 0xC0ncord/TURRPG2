//=============================================================================
// ArtifactPickup_Flight.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Flight extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_Flight'
    bAmbientGlow=False
    PickupMessage="You got the Flight artifact!"
    PickupSound=Sound'PickupSounds.SniperRiflePickup'
    PickupForce="SniperRiflePickup"
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.Flight'
    DrawScale=0.075000
    Physics=PHYS_Rotating
    RotationRate=(Yaw=24000)
}
