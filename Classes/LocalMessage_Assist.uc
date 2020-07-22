//=============================================================================
// LocalMessage_Assist.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//============================================================================
// RPGAssistLocalMessage
// Copyright 2007 by Jrubzjeknf <rrvanolst@hotmail.com>
//
// Show "ASSIST" on the screen whilst the Classic announcer shouts the same.
//
// generalized to "Score Assist" by pd
// ============================================================================

class LocalMessage_Assist extends CriticalEventPlus;

#EXEC OBJ LOAD FILE=AnnouncerClassic.uax

//============================================================================
// GetString
//============================================================================
static function string GetString(optional int Switch,
                      optional PlayerReplicationInfo RelatedPRI_1,
                      optional PlayerReplicationInfo RelatedPRI_2,
                      optional Object OptionalObject)
{
  return "Score Assist!";
}

//============================================================================
// ClientReceive - play sound
//============================================================================
static function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
  Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

  P.ClientPlaySound(Sound'AnnouncerClassic.assist');
}

//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     FontSize=2
}
