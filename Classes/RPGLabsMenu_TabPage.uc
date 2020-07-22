//=============================================================================
// RPGLabsMenu_TabPage.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGLabsMenu_TabPage extends MidGamePanel;

var RPGLabsMenu LabsMenu;

function InitMenu();
function CloseMenu();

event Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);
    LabsMenu = None;
}

defaultproperties
{
}
