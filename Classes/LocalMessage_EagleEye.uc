//=============================================================================
// LocalMessage_EagleEye.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//EAGLE EYE message for telefragging. :)  -pd

class LocalMessage_EagleEye extends LocalMessage;

var localized string DeathMessage;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
    return default.DeathMessage;
}

defaultproperties
{
    DeathMessage="Eagle Eye!"
    bIsUnique=True
    bFadeMessage=True
    Lifetime=5
    DrawColor=(B=0,G=0)
    StackMode=SM_Down
    PosY=0.100000
    FontSize=2
}
