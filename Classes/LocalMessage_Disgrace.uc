//=============================================================================
// LocalMessage_Disgrace.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//DISGRACE message for being telefragged. :(  -pd

class LocalMessage_Disgrace extends LocalMessage;

var localized string DeathMessage;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
    return default.DeathMessage;
}

defaultproperties
{
    DeathMessage="Disgrace!"
    bIsUnique=True
    bFadeMessage=True
    Lifetime=5
    DrawColor=(G=128,R=128)
    StackMode=SM_Down
    PosY=0.100000
    FontSize=2
}
