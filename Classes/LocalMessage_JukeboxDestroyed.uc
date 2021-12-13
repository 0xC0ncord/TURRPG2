//=============================================================================
// LocalMessage_JukeboxDestroyed.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_JukeboxDestroyed extends CriticalEventPlus;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return "The Jukebox was destroyed!";
}

defaultproperties
{
    Lifetime=3
    PosY=0.700000
    DrawColor=(R=255,G=0,B=0)
}
