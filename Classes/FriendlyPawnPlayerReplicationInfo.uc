//=============================================================================
// FriendlyPawnPlayerReplicationInfo.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FriendlyPawnPlayerReplicationInfo extends PlayerReplicationInfo;

event PreBeginPlay()
{
    // For some reason, monsters with a PRI on the client get Jakob models
    // and vehicles without a PRI on the client no longer rotate
    // Just... wtf?
    if(FriendlyMonsterController(Owner) != None)
        RemoteRole = ROLE_None;
}

defaultproperties
{
    bIsSpectator=True
    bBot=True
    bWelcomed=True
    bNetNotify=False
}
