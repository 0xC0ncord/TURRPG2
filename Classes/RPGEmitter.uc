//=============================================================================
// RPGEmitter.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGEmitter extends Emitter;

var bool bClientKill;

replication
{
    reliable if(Role == ROLE_Authority)
        bClientKill;
}

simulated function PostNetReceive()
{
    if(bClientKill)
        Kill();
}

function Die()
{
    Kill();
    bClientKill = true;
    bTearOff = true;
}

defaultproperties
{
    AutoDestroy=True
    bNoDelete=False
    RemoteRole=ROLE_SimulatedProxy
    bNotOnDedServer=False
}
