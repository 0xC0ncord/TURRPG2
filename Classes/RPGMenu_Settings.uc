class RPGMenu_Settings extends RPGMenu_TabPage;

var automated GUISectionBackground sbCustomize;

var automated GUIMultiOptionListBox lbSettings;
var automated moCheckBox chkWeaponExtra, chkArtifactText, chkExpGain, chkExpBar, chkHints, chkClassicArtifactSelection;
var automated moSlider slExpGain, slIconsPerRow, slIconScale, slIconsX, slIconsY, slExpBarX, slExpBarY;

var localized string Text_HintWeaponExtra;
var localized string Text_HintArtifactExtra;
var localized string Text_HintShowExpBar;
var localized string Text_HintShowHints;
var localized string Text_HintClassicArtifactSelection;
var localized string Text_HintExpGainDuration;
var localized string Text_HintIconsPerRow;
var localized string Text_HintIconScale;
var localized string Text_HintIconsX;
var localized string Text_HintIconsY;
var localized string Text_HintExpBarX;
var localized string Text_HintExpBarY;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    lbSettings.List.ColumnWidth = 0.45;
    lbSettings.List.bVerticalLayout = true;
    lbSettings.List.bHotTrack = true;

    chkWeaponExtra = moCheckBox(lbSettings.List.AddItem("XInterface.moCheckBox",, "Display extra information", true));
    chkArtifactText = moCheckBox(lbSettings.List.AddItem("XInterface.moCheckBox",, "Show Artifact name", true));
    chkExpBar = moCheckBox(lbSettings.List.AddItem("XInterface.moCheckBox",, "Show experience bar", true));
    chkHints = moCheckBox(lbSettings.List.AddItem("XInterface.moCheckBox",, "Display hints", true));
    chkClassicArtifactSelection = moCheckBox(lbSettings.List.AddItem("XInterface.moCheckBox",, "Use classic artifact selection", true));
    slExpGain = moSlider(lbSettings.List.AddItem("XInterface.moSlider",, "Experience gain duration", true));
    slIconsPerRow = moSlider(lbSettings.List.AddItem("XInterface.moSlider",, "Artifact icons per row", true));
    slIconScale = moSlider(lbSettings.List.AddItem("XInterface.moSlider",, "Artifact icon scale", true));
    slIconsX = moSlider(lbSettings.List.AddItem("XInterface.moSlider",, "Artifact icons X", true));
    slIconsY = moSlider(lbSettings.List.AddItem("XInterface.moSlider",, "Artifact icons Y", true));
    slExpBarX = moSlider(lbSettings.List.AddItem("XInterface.moSlider",, "Experience bar X", true));
    slExpBarY = moSlider(lbSettings.List.AddItem("XInterface.moSlider",, "Experience bar Y", true));

    chkWeaponExtra.ToolTip.SetTip(Text_HintWeaponExtra);
    chkArtifactText.ToolTip.SetTip(Text_HintArtifactExtra);
    chkExpBar.ToolTip.SetTip(Text_HintShowExpBar);
    chkHints.ToolTip.SetTip(Text_HintShowHints);
    chkClassicArtifactSelection.ToolTip.SetTip(Text_HintClassicArtifactSelection);
    slExpGain.ToolTip.SetTip(Text_HintExpGainDuration);
    slIconsPerRow.ToolTip.SetTip(Text_HintIconsPerRow);
    slIconScale.ToolTip.SetTip(Text_HintIconScale);
    slIconsX.ToolTip.SetTip(Text_HintIconsX);
    slIconsY.ToolTip.SetTip(Text_HintIconsY);
    slExpBarX.ToolTip.SetTip(Text_HintExpBarX);
    slExpBarY.ToolTip.SetTip(Text_HintExpBarY);

    slExpGain.Setup(0, 21, true);
    slIconsPerRow.Setup(1, 25, true);
    slIconScale.Setup(0.5, 1.5, false);
    slIconsX.Setup(0, 1, false);
    slIconsY.Setup(0, 1, false);
    slExpBarX.Setup(0, 1, false);
    slExpBarY.Setup(0, 1, false);

    SetDefaultComponent(chkWeaponExtra);
    SetDefaultComponent(chkArtifactText);
    SetDefaultComponent(chkExpBar);
    SetDefaultComponent(chkHints);
    SetDefaultComponent(chkClassicArtifactSelection);
    SetDefaultComponent(slExpGain);
    SetDefaultComponent(slIconsPerRow);
    SetDefaultComponent(slIconScale);
    SetDefaultComponent(slIconsX);
    SetDefaultComponent(slIconsY);
    SetDefaultComponent(slExpBarX);
    SetDefaultComponent(slExpBarY);
}

function SetDefaultComponent(GUIMenuOption PassedComponent)
{
    PassedComponent.CaptionWidth = 0.6;
    PassedComponent.ComponentWidth = 0.4;
    PassedComponent.ComponentJustification = TXTA_Right;
    PassedComponent.bStandardized = false;
    PassedComponent.bBoundToParent = false;
    PassedComponent.bScaleToParent = false;
    PassedComponent.MyLabel.TextAlign = TXTA_Left;
    PassedComponent.OnChange = InternalOnChange;
}

function InitMenu()
{
    chkWeaponExtra.Checked(!RPGMenu.RPRI.Interaction.Settings.bHideWeaponExtra);
    chkArtifactText.Checked(!RPGMenu.RPRI.Interaction.Settings.bHideArtifactName);
    chkExpBar.Checked(!RPGMenu.RPRI.Interaction.Settings.bHideExpBar);
    chkClassicArtifactSelection.Checked(RPGMenu.RPRI.Interaction.Settings.bClassicArtifactSelection);
    
    slExpGain.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.ExpGainDuration), true);
    slExpBarX.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.ExpBarX), true);
    slExpBarY.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.ExpBarY), true);
    if(chkExpBar.IsChecked())
    {
        slExpGain.MySlider.MenuState = MSAT_Blurry;
        slExpBarX.MySlider.MenuState = MSAT_Blurry;
        slExpBarY.MySlider.MenuState = MSAT_Blurry;
    }
    else
    {
        slExpGain.MySlider.MenuState = MSAT_Disabled;
        slExpBarX.MySlider.MenuState = MSAT_Disabled;
        slExpBarY.MySlider.MenuState = MSAT_Disabled;
    }
    
    slIconsPerRow.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.IconsPerRow), true);
    if(chkClassicArtifactSelection.IsChecked())
        slIconsPerRow.MySlider.MenuState = MSAT_Disabled;
    else
        slIconsPerRow.MySlider.MenuState = MSAT_Blurry;

    slIconScale.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.IconScale), true);
    slIconsX.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.IconsX), true);
    
    if(chkClassicArtifactSelection.IsChecked())
        slIconsY.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.IconClassicY), true);
    else
        slIconsY.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.IconsY), true);
}

function InternalOnChange(GUIComponent Sender)
{
    RPGMenu.RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    switch(Sender)
    {
        case chkWeaponExtra:
            RPGMenu.RPRI.Interaction.Settings.bHideWeaponExtra = !chkWeaponExtra.IsChecked();
            break;
            
        case chkArtifactText:
            RPGMenu.RPRI.Interaction.Settings.bHideArtifactName = !chkArtifactText.IsChecked();
            break;
            
        case chkExpBar:
            RPGMenu.RPRI.Interaction.Settings.bHideExpBar = !chkExpBar.IsChecked();
            
            if(chkExpBar.IsChecked())
            {
                slExpGain.MySlider.MenuState = MSAT_Blurry;
                slExpBarX.MySlider.MenuState = MSAT_Blurry;
                slExpBarY.MySlider.MenuState = MSAT_Blurry;
            }
            else
            {
                slExpGain.MySlider.MenuState = MSAT_Disabled;
                slExpBarX.MySlider.MenuState = MSAT_Disabled;
                slExpBarY.MySlider.MenuState = MSAT_Disabled;
            }

            break;
            
        case slExpGain:
            RPGMenu.RPRI.Interaction.Settings.ExpGainDuration = float(slExpGain.GetComponentValue());
            break;
            
        case slIconsPerRow:
            RPGMenu.RPRI.Interaction.Settings.IconsPerRow = int(slIconsPerRow.GetComponentValue());
            break;
            
        case slIconScale:
            RPGMenu.RPRI.Interaction.Settings.IconScale = float(slIconScale.GetComponentValue());
            break;
            
        case slExpBarX:
            RPGMenu.RPRI.Interaction.Settings.ExpBarX = float(slExpBarX.GetComponentValue());
            break;

        case slExpBarY:
            RPGMenu.RPRI.Interaction.Settings.ExpBarY = float(slExpBarY.GetComponentValue());
            break;
            
        case slIconsX:
            RPGMenu.RPRI.Interaction.Settings.IconsX = float(slIconsX.GetComponentValue());
            break;
            
        case slIconsY:
            if(chkClassicArtifactSelection.IsChecked())
                RPGMenu.RPRI.Interaction.Settings.IconClassicY = float(slIconsY.GetComponentValue());
            else
                RPGMenu.RPRI.Interaction.Settings.IconsY = float(slIconsY.GetComponentValue());
                
            break;
        
        case chkExpGain:
            RPGMenu.RPRI.Interaction.Settings.bHideExpGain = !chkExpGain.IsChecked();
            break;

        case chkClassicArtifactSelection:
            RPGMenu.RPRI.Interaction.Settings.bClassicArtifactSelection = chkClassicArtifactSelection.IsChecked();
            
            if(chkClassicArtifactSelection.IsChecked())
                slIconsPerRow.MySlider.MenuState = MSAT_Disabled;
            else
                slIconsPerRow.MySlider.MenuState = MSAT_Blurry;
            
            if(chkClassicArtifactSelection.IsChecked())
                slIconsY.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.IconClassicY), true);
            else
                slIconsY.SetComponentValue(string(RPGMenu.RPRI.Interaction.Settings.IconsY), true);
            
            break;
        
        case chkHints:
            RPGMenu.RPRI.Interaction.Settings.bHideHints = !chkHints.IsChecked();
            break;
    }
    
    RPGMenu.RPRI.Interaction.bUpdateCanvas = true;
}

defaultproperties
{
    Begin Object Class=AltSectionBackground Name=sbCustomize_
        Caption="TURRPG Settings"
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
        StyleName="ServerBrowserGrid"
        WinTop=0.101564
        WinLeft=0.034118
        WinWidth=0.931141
        WinHeight=0.751637
        bBoundToParent=True
        bScaleToParent=True
    End Object
    lbSettings=GUIMultiOptionListBox'RPGMenu_Settings.lbSettings_'

    Text_HintWeaponExtra="If checked, a short description about a weapon's magic is displayed below its name when selected. Also controls the extra description for artifacts."
    Text_HintArtifactExtra="If checked, the name of an artifact is displayed on the screen when selecting one (similar to weapons)."
    Text_HintShowExpBar="If checked, your level, experience and experience gain is displayed on the right side of your screen."
    Text_HintClassicArtifactSelection="If checked, only the currently selected artifact will be displayed on the screen like in the old UT2004 RPG versions."
    Text_HintExpGainDuration="Select for how many seconds your exp gain should be displayed below the experience bar. 0 means never display, 21 means display for the whole match."
    Text_HintIconsPerRow="Determine how many artifact icons can be displayed in one vertical row."
    Text_HintIconScale="Determine the scale of the artifact icons."
    Text_HintIconsX="Determine the X position of the artifact icon(s)."
    Text_HintIconsY="Determine the Y position of the artifact icon(s)."
    Text_HintExpBarX="Determine the X position of the experience bar."
    Text_HintExpBarY="Determine the Y position of the experience bar."

    WinHeight=0.700000
}
