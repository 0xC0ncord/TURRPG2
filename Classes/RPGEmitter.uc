//=============================================================================
// RPGEmitter.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGEmitter extends Emitter;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientKill;
}

simulated function ClientKill()
{
    Kill();
}

defaultproperties
{
    AutoDestroy=True
    bNoDelete=False
    RemoteRole=ROLE_SimulatedProxy
    bNotOnDedServer=False
}
