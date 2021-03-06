//=============================================================================
// LocalMessage_VehicleLocked.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_VehicleLocked extends LocalMessage;

var localized string LockedMessage, LockedByMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
                 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    if(RelatedPRI_1 == None)
        return default.LockedMessage;
    return (default.LockedByMessage @ RelatedPRI_1.PlayerName);
}

defaultproperties
{
     LockedMessage="This vehicle has been locked."
     LockedByMessage="This vehicle has been locked by"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=0,G=0)
     PosY=0.750000
}
