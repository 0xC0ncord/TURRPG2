//=============================================================================
// ArtifactPickup_Record.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Record extends RPGArtifactPickup;

var FX_RecordPickup FX;

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    FX = Spawn(class'FX_RecordPickup', self,, Location);
    if(StaticMesh != None)
    {
        MeshEmitter(FX.Emitters[0]).StaticMesh = StaticMesh;
        FX.Emitters[0].Disabled = False;
    }
}

simulated function Destroyed()
{
    Super.Destroyed();
    if(FX != None)
        FX.Destroy();
}

defaultproperties
{
     InventoryType=Class'ArtifactBase_Record'
     PickupMessage="You got a Music Disc!"
     DrawType=DT_None
}
