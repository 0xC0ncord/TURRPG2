//=============================================================================
// RPGMenu_ControlBinderFakeTab.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMenu_ControlBinderFakeTab extends RPGMenu_TabPage;

function ShowPanel(bool bShow)
{
    if(bShow)
        Controller.OpenMenu("TURRPG2.RPGMenu_ControlBinder");

    Super.ShowPanel(bShow);
}

function CloseMenu()
{
    RPGMenu.RPRI.Interaction.CheckBindings();
}

defaultproperties
{
    WinHeight=0.700000
}
