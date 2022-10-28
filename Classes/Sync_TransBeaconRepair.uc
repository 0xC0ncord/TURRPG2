//=============================================================================
// Sync_TransBeaconRepair.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Sync_TransBeaconRepair extends Sync;

var TransBeacon Beacon;

//Identifiers
var vector ProjLoc;
var Pawn ProjInstigator;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Beacon, ProjLoc, ProjInstigator;
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if(Role < Role_Authority)
        ClientFunction();
}

simulated function bool ClientFunction()
{
    local TransBeacon B;

    if(Beacon == None)
    {
        foreach DynamicActors(class'TransBeacon', B)
        {
            if(VSize(B.Location - ProjLoc) < 256 && B.Instigator == ProjInstigator)
            {
                Beacon = B;
                break;
            }
        }
    }

    if(Beacon != None)
    {
        Beacon.Disruptor = None;
        Beacon.Disruption = 0;
        if(Beacon.Sparks != None)
        {
            Beacon.Sparks.Detach(Beacon);
            Beacon.Sparks.Destroy();
            Beacon.SetTimer(0.3, false); // so it may do sparks again if it gets damaged
        }
        if(Beacon.Flare == None)
        {
            Beacon.Flare = Beacon.Spawn(Beacon.TransFlareClass, Beacon,, Beacon.Location - vect(0, 0, 5), rot(16384, 0, 0));
            Beacon.Flare.SetBase(Beacon);
        }
    }

    return true;
}

defaultproperties
{
}
