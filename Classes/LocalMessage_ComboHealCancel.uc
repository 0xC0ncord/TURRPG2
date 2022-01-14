//=============================================================================
// LocalMessage_ComboHealCancel.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_ComboHealCancel extends LocalMessage;

var localized string ComboCancelled;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return default.ComboCancelled;
}

defaultproperties
{
    ComboCancelled="Combo cancelled - health and shields already full!"
    bIsUnique=True
    bFadeMessage=True
    DrawColor=(B=0,G=0)
    StackMode=SM_Down
    PosY=0.100000
}
