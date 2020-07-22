//=============================================================================
// RPGArtifactPickup.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGArtifactPickup extends TournamentPickup;

function float DetourWeight(Pawn Other, float PathWeight) {
    return MaxDesireability/PathWeight;
}

defaultproperties {
    MaxDesireability=1.500000
    PickupSound=Sound'PickupSounds.SniperRiflePickup'
    PickupForce="SniperRiflePickup"
    AmbientGlow=128
    DrawType=DT_StaticMesh
    Physics=PHYS_Rotating
    RotationRate=(Yaw=24000)
}
