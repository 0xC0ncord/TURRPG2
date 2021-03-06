//=============================================================================
// LocalMessage_TeamBooster.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_TeamBooster extends ComboMessage;

var localized string MessageText, DisabledMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if(Switch == 0)
        return Repl(default.MessageText, "$1", RelatedPRI_1.PlayerName);
    else
        return Repl(default.DisabledMessage, "$1", RelatedPRI_1.PlayerName);
}

defaultproperties
{
    MessageText="Team Booster by $1!"
    DisabledMessage="$1 is already boosting your team!"
    Lifetime=5 //little longer than the usual message
}
