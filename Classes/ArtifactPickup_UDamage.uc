//=============================================================================
// ArtifactPickup_UDamage.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_UDamage extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_UDamage'
    PickupMessage="You got the Double Damage!"
    PickupSound=Sound'PickupSounds.UDamagePickup'
    PickupForce="UDamagePickup"
    StaticMesh=StaticMesh'E_Pickups.General.Udamage'
    DrawScale=0.900000
    AmbientGlow=255
    ScaleGlow=0.600000
    Style=STY_AlphaZ
}
