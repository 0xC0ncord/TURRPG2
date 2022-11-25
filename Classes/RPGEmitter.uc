//=============================================================================
// RPGEmitter.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGEmitter extends Emitter;

simulated function TornOff()
{
    Kill();
}

function Die()
{
    Kill();
    bTearOff = true;
}

defaultproperties
{
    AutoDestroy=True
    bNoDelete=False
    RemoteRole=ROLE_SimulatedProxy
    bNotOnDedServer=False
}
