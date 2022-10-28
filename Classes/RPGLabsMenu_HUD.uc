//=============================================================================
// RPGLabsMenu_HUD.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGLabsMenu_HUD extends RPGLabsMenu_TabPage
    dependson(RPGSettings);

var automated GUISectionBackground sbCustomize;
var automated GUIMultiOptionListBox lbSettings;

var automated moComboBox cbXPHudStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    cbXPHudStyle = moComboBox(lbSettings.List.AddItem("XInterface.moComboBox",, "XP HUD Style", true));
    cbXPHudStyle.AddItem("Classic");

    SetDefaultComponent(cbXPHudStyle);
}

function SetDefaultComponent(GUIMenuOption PassedComponent)
{
    PassedComponent.CaptionWidth = 0.6;
    PassedComponent.ComponentWidth = 0.4;
    PassedComponent.ComponentJustification = TXTA_Right;
    PassedComponent.bStandardized = false;
    PassedComponent.bBoundToParent = false;
    PassedComponent.bScaleToParent = false;
    PassedComponent.OnChange = InternalOnChange;

    if(PassedComponent.MyLabel != None)
        PassedComponent.MyLabel.TextAlign = TXTA_Left;

    switch(PassedComponent.Class)
    {
        case class'moComboBox':
            moComboBox(PassedComponent).MyComboBox.Edit.bReadOnly = true;
    }
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if(Sender == lbSettings && lbSettings.List != None)
    {
        lbSettings.List.ColumnWidth = 0.45;
        lbSettings.List.bVerticalLayout = true;
        lbSettings.List.bHotTrack = true;
    }
}

function InitMenu()
{
    cbXPHudStyle.SetIndex(LabsMenu.RPRI.Interaction.Settings.XPHudStyle);
}

function InternalOnChange(GUIComponent Sender)
{
    LabsMenu.RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    switch(Sender)
    {
        case cbXPHudStyle:
            LabsMenu.RPRI.Interaction.Settings.XPHudStyle = cbXPHudStyle.GetIndex();
    }

    LabsMenu.RPRI.Interaction.bUpdateCanvas = true;
}

defaultproperties
{
    Begin Object Class=AltSectionBackground Name=sbCustomize_
        Caption="Labs"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.997718
        WinHeight=0.929236
        WinLeft=0.000085
        WinTop=0.013226
        OnPreDraw=sbCustomize_.InternalPreDraw
    End Object
    sbCustomize=AltSectionBackground'sbCustomize_'

    Begin Object Class=GUIMultiOptionListBox Name=lbSettings_
        bVisibleWhenEmpty=True
        OnCreateComponent=RPGLabsMenu_HUD.InternalOnCreateComponent
        StyleName="ServerBrowserGrid"
        WinTop=0.101564
        WinLeft=0.034118
        WinWidth=0.931141
        WinHeight=0.751637
        bBoundToParent=True
        bScaleToParent=True
    End Object
    lbSettings=GUIMultiOptionListBox'RPGLabsMenu_HUD.lbSettings_'

    WinHeight=0.700000
}
