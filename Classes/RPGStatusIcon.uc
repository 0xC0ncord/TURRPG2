//=============================================================================
// RPGStatusIcon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//client side only
class RPGStatusIcon extends Object;

var RPGPlayerReplicationInfo RPRI;

var Material IconMaterial; //the icon texture to display
var bool bShouldTick; //whether Tick is called each frame or not

//abstract
function Initialize(); //initialize, the RPRI is already set at this point
function Tick(float dt); //tick

function bool IsVisible(); //determines whether this icon should currently be displayed
function string GetText(); //retrieves the text to display on this icon

defaultproperties
{
}
