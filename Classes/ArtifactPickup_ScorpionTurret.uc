//=============================================================================
// ArtifactPickup_ScorpionTurret.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_ScorpionTurret extends RPGArtifactPickup;

defaultproperties {
    DrawScale=0.75
    InventoryType=Class'Artifact_ScorpionTurret'
    PickupMessage="You got the Scorpion Turret Switcher!"
    DrawType=DT_Mesh
    Mesh=Mesh'ONSWeapons-A.RVnewGun'
    PrePivot=(X=0,Y=0,Z=-24)
}
