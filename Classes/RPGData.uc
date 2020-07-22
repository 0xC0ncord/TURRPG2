//=============================================================================
// RPGData.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGData extends Object
    config(TURRPG2PlayerData)
    PerObjectConfig;

//Player name is the object name
var config string ID; //owner GUID ("Bot" for bots)

var config int LV; //level
var config float XP; //experience
var config int XN; //experience needed
var config int SPA, APA; //stat points available, ability points available

var config array<string> AB; //ability aliases (mapped to class refs in RPGPlayerReplicationInfo)
var config array<int> AL; //ability levels

//AI
var config string AI;
var config int AA;

defaultproperties
{
}
