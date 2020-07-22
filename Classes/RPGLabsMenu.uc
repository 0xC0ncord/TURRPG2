//=============================================================================
// RPGLabsMenu.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGLabsMenu extends FloatingWindow;

var RPGPlayerReplicationInfo RPRI;

var array<GUITabItem> Panels;
var automated GUITabControl Tabs;

var localized string WindowTitle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);

    for(i = 0; i < Panels.Length; i++)
    {
        //Prepend package name to class name
        Panels[i].ClassName = "TURRPG2." $ Panels[i].ClassName;

        Tabs.AddTabItem(Panels[i]);
    }

    t_WindowTitle.SetCaption(WindowTitle);
    t_WindowTitle.DockedTabs = Tabs;
}

function InitFor(RPGPlayerReplicationInfo Whom)
{
    local int i;

    RPRI = Whom;

    for(i = 0; i < Tabs.TabStack.Length; i++)
    {
        RPGLabsMenu_TabPage(Tabs.TabStack[i].MyPanel).LabsMenu = Self;
        RPGLabsMenu_TabPage(Tabs.TabStack[i].MyPanel).InitMenu();
    }
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    local int i;

    for(i = 0; i < Tabs.Controls.Length; i++)
        RPGLabsMenu_TabPage(Tabs.Controls[i]).CloseMenu();

    if(RPRI != None)
    {
        RPRI.Interaction.Settings.SaveConfig();
        RPRI.Interaction.CharSettings.SaveConfig();
    }

    Super.Closed(Sender, bCancelled);
}

event Free()
{
    Super.Free();
    RPRI = None;
}

defaultproperties
{
    Panels(0)=(ClassName="RPGLabsMenu_HUD",Caption="HUD",Hint="HUD settings.")

    Begin Object Class=GUITabControl Name=RPGLabsMenuTC
        bFillSpace=True
        bDockPanels=True
        TabHeight=0.037500
        BackgroundStyleName="TabBackground"
        WinTop=0.05
        WinLeft=0.01
        WinWidth=0.98
        WinHeight=0.05
        bScaleToParent=True
        bAcceptsInput=True
        OnActivate=RPGLabsMenuTC.InternalOnActivate
    End Object
    Tabs=GUITabControl'RPGLabsMenuTC'

    bResizeWidthAllowed=False
    bResizeHeightAllowed=False
    bMoveAllowed=False
    bPersistent=True
    bAllowedAsLast=True

    WinLeft=0.10
    WinTop=0.10
    WinWidth=0.80
    WinHeight=0.80

    WindowTitle="TURRPG Labs Menu"
}
