//=============================================================================
// ArtifactPickup_Jukebox.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactPickup_Jukebox extends RPGArtifactPickup;

var Emitter FX;

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    FX = Spawn(class'FX_JukeboxPickup', self,, Location);
}

simulated function Destroyed()
{
    Super.Destroyed();
    if(FX != None)
        FX.Destroy();
}

defaultproperties
{
     InventoryType=Class'Artifact_Jukebox'
     PickupMessage="You got the Jukebox!"
     DrawType=DT_None
}
