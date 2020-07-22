//=============================================================================
// LocalMessage_FriendlyMonsterKiller.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_FriendlyMonsterKiller extends xKillerMessagePlus;

var localized string YourMonsterKilled;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if(RelatedPRI_2 == None || OptionalObject == None || Pawn(OptionalObject) == None)
        return "";

    if(RelatedPRI_2.PlayerName != "")
        return default.YourMonsterKilled @ RelatedPRI_2.PlayerName @ default.YouKilledTrailer;
}

defaultproperties
{
    YourMonsterKilled="Your Monster killed"
}
