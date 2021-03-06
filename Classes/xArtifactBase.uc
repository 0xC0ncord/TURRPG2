//=============================================================================
// xArtifactBase.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class xArtifactBase extends xPickUpBase placeable;

var() class<RPGArtifact> ArtifactType;
var() float RespawnTime;

simulated event PostBeginPlay()
{
    if(ArtifactType != None)
        PowerUp = ArtifactType.default.PickupClass;

    Super.PostBeginPlay();

    SetLocation(Location + vect(0, 0, -1));
}

function SpawnPickup() {
    Super.SpawnPickup();

    if(myPickup != None) {
        //Artifact pickups don't have a respawn time by default
        myPickup.RespawnTime = RespawnTime;
    }
}

defaultproperties
{
    RespawnTime=30.00
    bDelayedSpawn=False

    DrawScale=0.8
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'XGame_rc.AmmoChargerMesh'
    SpiralEmitter=class'XEffects.Spiral'

    CollisionRadius=60.000000
    CollisionHeight=6.000000
}
