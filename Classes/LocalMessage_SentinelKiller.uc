//=============================================================================
// LocalMessage_SentinelKiller.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_SentinelKiller extends xKillerMessagePlus;

var localized string YourSentinelKilled;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if(RelatedPRI_2 == None || OptionalObject == None || Vehicle(OptionalObject) == None)
        return "";

    if(RelatedPRI_2.PlayerName != "")
        return Repl(default.YourSentinelKilled, "$1", Vehicle(OptionalObject).VehicleNameString) @ RelatedPRI_2.PlayerName @ default.YouKilledTrailer;
}

defaultproperties
{
    YourSentinelKilled="Your $1 killed"
}
