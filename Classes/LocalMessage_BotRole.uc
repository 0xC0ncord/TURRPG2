//=============================================================================
// LocalMessage_BotRole.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_BotRole extends TeamSayMessagePlus;
//TODO CTF4

var localized array<string> RoleText;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return RelatedPRI_1.PlayerName $ ":" @ default.RoleText[Switch];
}

defaultproperties {
    bBeep=False
    RoleText(0)="I'm a medic!";
}
