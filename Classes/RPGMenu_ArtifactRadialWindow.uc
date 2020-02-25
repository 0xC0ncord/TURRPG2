class RPGMenu_ArtifactRadialWindow extends FloatingWindow
    DependsOn(RPGCharSettings);

var RPGPlayerReplicationInfo RPRI;
var bool bDirty;
var bool bIgnoreNextChange;

var array<RPGPlayerReplicationInfo.RadialMenuArtifactStruct> AllElements;

var automated GUISectionBackground sbArtifacts, sbRadialArtifacts, sbArtifact, sbRadial, sbGlobalSettings;
var automated GUIListBox lbArtifacts, lbRadialArtifacts;
var automated GUIMultiOptionListBox lbSettings;
var automated GUIMultiOptionListBox lbGlobalSettings;
var automated GUIGFXButton btAdd, btRemove;
var automated GUIGFXButton btUp, btDown;
var automated GUIImage imIcon;
var automated GUIScrollTextBox lbDesc;
var automated GUIButton btHelp;

var automated moCheckBox chShowAlways;

var automated moCheckBox chEnableRadialMenu;
var automated moCheckBox chShowAll;
var automated moSlider slAnimSpeed;
var automated moSlider slMouseSens;

var localized string WindowTitle;

var localized string NotAvailableText, NotAvailableTitle, NotAvailableDesc;

var localized string Text_HintShowAlways;

var localized string Text_HintEnableRadialMenu;
var localized string Text_HintShowAll;
var localized string Text_HintAnimSpeed;
var localized string Text_HintMouseSens;
var localized string Text_HintHelp;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    lbArtifacts.List.OnDragDrop = RemoveArtifactDrop;
    lbArtifacts.List.bInitializeList = false;
    lbArtifacts.List.bDropSource = true;
    lbArtifacts.List.bDropTarget = true;
    lbArtifacts.List.bMultiSelect = true;
    lbArtifacts.List.bSorted = true;

    lbRadialArtifacts.List.OnDragDrop = AddArtifactDrop;
    lbRadialArtifacts.List.bInitializeList = false;
    lbRadialArtifacts.List.bDropSource = true;
    lbRadialArtifacts.List.bDropTarget = true;
    lbRadialArtifacts.List.bMultiSelect = true;

    lbArtifacts.List.OnDblClick = ArtifactsDoubleClick;
    lbRadialArtifacts.List.OnDblClick = RadialArtifactsDoubleClick;

    lbArtifacts.List.CheckLinkedObjects = InternalCheckObjects;
    lbArtifacts.List.AddLinkObject(btAdd, true);

    lbRadialArtifacts.List.CheckLinkedObjects = InternalCheckObjects;
    lbRadialArtifacts.List.AddLinkObject(btRemove, true);

    lbArtifacts.List.DisableLinkedObjects();
    lbRadialArtifacts.List.DisableLinkedObjects();
    InternalCheckObjects(None);

    lbArtifacts.OnClick = Clicked;
    lbRadialArtifacts.OnClick = Clicked;

    lbArtifacts.OnKeyEvent = ListKeyEvent;
    lbRadialArtifacts.OnKeyEvent = RadialListKeyEvent;

    lbGlobalSettings.List.ColumnWidth = 0.45;
    lbGlobalSettings.List.ItemScaling = 0.035;
    lbGlobalSettings.List.bVerticalLayout = true;
    lbGlobalSettings.List.bHotTrack = true;

    //settings
    chShowAlways = moCheckBox(lbSettings.List.AddItem("XInterface.moCheckBox",, "Show always", true));

    chShowAlways.ToolTip.SetTip(Text_HintShowAlways);

    SetDefaultComponent(chShowAlways);

    //global settings
    chEnableRadialMenu = moCheckBox(lbGlobalSettings.List.AddItem("XInterface.moCheckBox",, "Enable artifact radial menu", true));
    chShowAll = moCheckBox(lbGlobalSettings.List.AddItem("XInterface.moCheckBox",, "Always show all artifacts", true));
    slAnimSpeed = moSlider(lbGlobalSettings.List.AddItem("XInterface.moSlider",, "Animation speed", true));
    slMouseSens = moSlider(lbGlobalSettings.List.AddItem("XInterface.moSlider",, "Mouse sensitivity multiplier", true));

    chEnableRadialMenu.ToolTip.SetTip(Text_HintEnableRadialMenu);
    chShowAll.ToolTip.SetTip(Text_HintShowAll);
    slAnimSpeed.ToolTip.SetTip(Text_HintAnimSpeed);
    slMouseSens.ToolTip.SetTip(Text_HintMouseSens);

    SetDefaultComponent(chEnableRadialMenu);
    SetDefaultComponent(chShowAll);
    SetDefaultComponent(slAnimSpeed);
    SetDefaultComponent(slMouseSens);

    slAnimSpeed.Setup(1, 3, false);
    slMouseSens.Setup(1, 3, false);

    t_WindowTitle.SetCaption(WindowTitle);
    btHelp.ToolTip.SetTip(Text_HintHelp);

    OnRendered = DrawRadialPreview;
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

function InitFor(RPGPlayerReplicationInfo Whom)
{
    local class<RPGArtifact> AClass;
    local int i, x;
    local bool bShowAll;
    local bool bFound;

    RPRI = Whom;

    lbRadialArtifacts.List.bNotify = false;
    lbRadialArtifacts.List.Clear();
    AllElements = RPRI.ArtifactRadialMenuOrder;
    bShowAll = (AllElements.Length > 0);
    for(i = 0; i < AllElements.Length; i++)
    {
        if(bShowAll)
            bShowAll = bShowAll && AllElements[i].bShowAlways;
        AClass = AllElements[i].ArtifactClass;

        if(AClass != None)
            lbRadialArtifacts.List.Add(AClass.default.ItemName, AClass, string(i));
        else
            lbRadialArtifacts.List.Add(NotAvailableText @ AClass.default.ArtifactID, None, string(i));
    }
    lbRadialArtifacts.List.bNotify = true;

    lbArtifacts.List.bNotify = false;
    lbArtifacts.List.Clear();
    for(i = 0; i < RPRI.AllArtifacts.Length; i++)
    {
        AClass = RPRI.AllArtifacts[i];

        for(x = 0; x < lbRadialArtifacts.List.Elements.Length; x++)
        {
            if(lbRadialArtifacts.List.Elements[x].ExtraData == AClass)
            {
                bFound = true;
                break;
            }
        }
        if(bFound)
        {
            bFound = false;
            continue;
        }

        x = AllElements.Length;
        AllElements.Length = x + 1;
        AllElements[x].ArtifactClass = AClass;
        AllElements[x].ArtifactID = AClass.default.ArtifactID;

        if(AClass != None)
            lbArtifacts.List.Add(AClass.default.ItemName, AClass, string(x));
        else
            lbArtifacts.List.Add(NotAvailableText @ AClass.default.ArtifactID, None, string(x));
    }
    lbArtifacts.List.bNotify = true;

    lbArtifacts.List.SilentSetIndex(0);
    lbRadialArtifacts.List.SilentSetIndex(0);
    SelectArtifact();

    bIgnoreNextChange = true;
    chShowAll.Checked(bShowAll);
    chEnableRadialMenu.Checked(RPRI.Interaction.Settings.bEnableArtifactRadialMenu);
    slAnimSpeed.SetValue(RPRI.Interaction.Settings.ArtifactRadialMenuAnimSpeed);
    slMouseSens.SetValue(RPRI.Interaction.Settings.ArtifactRadialMenuMouseSens);
    bIgnoreNextChange = false;
}

function DrawRadialPreview(Canvas C)
{
    local float RadialSize;
    local int i;
    local RPGInteraction.Vec2 RadialPos, ArtifactPos;
    local class<RPGArtifact> AClass;

    RadialSize = FMin(RPRI.Interaction.ArtifactRadialSize * (C.ClipX / 1920), FMin(sbRadial.ActualWidth(), sbRadial.ActualHeight()) * 0.4);
    RadialPos.X = sbRadial.ActualLeft() + sbRadial.ActualWidth() * 0.5;
    RadialPos.Y = sbRadial.ActualTop() + sbRadial.ActualHeight() * 0.5;

    C.Style = 5; // STY_Alpha
    C.DrawColor = RPRI.Interaction.GetHUDTeamColor(HudCDeathmatch(Controller.ViewportOwner.Actor.myHUD));
    C.DrawColor.A = 150;
    C.SetPos(RadialPos.X - RadialSize, RadialPos.Y - RadialSize);
    C.DrawTile(TexRotator'ArtifactRadial1Rot', RadialSize * 2, RadialSize * 2, 0, 0, 256, 256);
    C.SetPos(RadialPos.X - RadialSize, RadialPos.Y - RadialSize);
    C.DrawTile(TexRotator'ArtifactRadial2Rot', RadialSize * 2, RadialSize * 2, 0, 0, 256, 256);

    C.DrawColor = RPRI.Interaction.WhiteColor;
    for(i = 0; i < lbRadialArtifacts.List.Elements.Length; i++)
    {
        AClass = class<RPGArtifact>(lbRadialArtifacts.List.GetObjectAtIndex(i));
        if(AClass == None)
            continue;

        ArtifactPos = class'RPGInteraction'.static.GetArtifactRadialPosition(i, lbRadialArtifacts.List.Elements.Length, RadialSize * 0.9, 1f);
        C.SetPos(RadialPos.X + ArtifactPos.X - (32 * (C.ClipX / 1920)), RadialPos.Y + ArtifactPos.Y - (32 * (C.ClipX / 1920)));
        C.DrawTile(AClass.default.IconMaterial, 64 * (C.ClipX / 1920), 64 * (C.ClipX / 1920), 0, 0, AClass.default.IconMaterial.MaterialUSize(), AClass.default.IconMaterial.MaterialVSize());
    }
}

function SelectArtifact(optional GUIList List)
{
    local class<RPGArtifact> AClass;

    RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    if(List == None)
        List = lbArtifacts.List;

    AClass = class<RPGArtifact>(List.GetObjectAtIndex(List.Index));
    if(AClass != None)
    {
        sbArtifact.Caption = AClass.default.ItemName;
        lbDesc.setContent(AClass.static.GetArtifactNameExtra());

        imIcon.Image = Texture(AClass.default.IconMaterial);
        imIcon.SetVisibility(true);

        if(chShowAlways.MenuState == MSAT_Disabled)
        {
            bIgnoreNextChange = true;
            chShowAlways.EnableMe();
            bIgnoreNextChange = false;
        }
    }
    else
    {
        sbArtifact.Caption = NotAvailableTitle;
        lbDesc.setContent(NotAvailableDesc);
        imIcon.Image = None;

        if(chShowAlways.MenuState != MSAT_Disabled)
        {
            bIgnoreNextChange = true;
            chShowAlways.DisableMe();
            bIgnoreNextChange = false;
        }
    }

    if(List == lbArtifacts.List)
    {
        bIgnoreNextChange = true;
        if(chShowAlways.MenuState != MSAT_Disabled)
            chShowAlways.DisableMe();
        chShowAlways.Checked(false);
        bIgnoreNextChange = false;
    }
    else if(List == lbRadialArtifacts.List)
    {
        bIgnoreNextChange = true;
        if(List.IsValid())
        {
            if(chShowAlways.MenuState == MSAT_Disabled)
                chShowAlways.EnableMe();
            if(List.Index > -1)
                chShowAlways.Checked(AllElements[List.Index].bShowAlways);
        }
        else
        {
            if(chShowAlways.MenuState != MSAT_Disabled)
                chShowAlways.DisableMe();
            chShowAlways.Checked(false);
        }
        bIgnoreNextChange = false;
    }
}

function InternalCheckObjects(GUIListBase List)
{
    if(List != None)
    {
        if(List.IsValid())
            List.EnableLinkedObjects();
        else
            List.DisableLinkedObjects();
    }

    if(lbArtifacts.List.ItemCount > 0)
        EnableComponent(btAdd);
    else
        DisableComponent(btAdd);

    if(lbRadialArtifacts.List.ItemCount > 0)
        EnableComponent(btRemove);
    else
        DisableComponent(btRemove);
}

function bool ArtifactsDoubleClick(GUIComponent Sender)
{
    AddArtifact(Sender);
    return true;
}

function bool RadialArtifactsDoubleClick(GUIComponent Sender)
{
    RemoveArtifact(Sender);
    return true;
}

function ListChange(GUIComponent Sender)
{
    if(Sender == lbArtifacts)
    {
        lbArtifacts.List.SilentSetIndex(-1);
        InternalCheckObjects(lbArtifacts.List);
    }
    else if(Sender == lbRadialArtifacts)
    {
        lbRadialArtifacts.List.SilentSetIndex(-1);
        InternalCheckObjects(lbRadialArtifacts.List);
    }
}

function bool AddArtifact(GUIComponent Sender)
{
    local array<GUIListElem> PendingElements;
    local int i;

    if(!lbArtifacts.List.IsValid())
        return true;

    PendingElements = lbArtifacts.List.GetPendingElements(true);

    lbArtifacts.List.bNotify = false;
    for(i = PendingElements.Length - 1; i >= 0; i--)
    {
        lbArtifacts.List.RemoveElement(PendingElements[i],, true);
        lbRadialArtifacts.List.AddElement(PendingElements[i]);

        AllElements[int(PendingElements[i].ExtraStrData)].bShowAlways = chShowAll.IsChecked();
    }

    lbArtifacts.List.bNotify = true;
    lbArtifacts.List.ClearPendingElements();
    lbArtifacts.List.SetIndex(lbArtifacts.List.Index); //to check if button states should change

    if(lbArtifacts.List.bSorted)
        lbArtifacts.List.Sort();

    bDirty = true;

    return true;
}

function bool RemoveArtifact(GUIComponent Sender)
{
    local array<GUIListElem> PendingElements;
    local int i;

    if(!lbRadialArtifacts.List.IsValid())
        return true;

    PendingElements = lbRadialArtifacts.List.GetPendingElements(true);
    lbRadialArtifacts.List.bNotify = false;
    for(i = PendingElements.Length - 1; i >= 0; i--)
    {
        lbRadialArtifacts.List.RemoveElement(PendingElements[i],, true);
        lbArtifacts.List.AddElement(PendingElements[i]);
    }

    lbRadialArtifacts.List.bNotify = true;
    lbRadialArtifacts.List.ClearPendingElements();

    bDirty = true;

    return true;
}

function bool AddArtifactDrop(GUIComponent Sender)
{
    if(Controller == None)
        return false;

    if(!lbArtifacts.List.IsValid())
        return true;

    bDirty = true;

    return lbRadialArtifacts.List.InternalOnDragDrop(Sender);
}

function bool RemoveArtifactDrop(GUIComponent Sender)
{
    if(Controller == None || Controller.DropSource != lbRadialArtifacts.List)
        return false;

    bDirty = true;

    return lbArtifacts.List.InternalOnDragDrop(Sender);
}

function SwapArtifacts(int i, int x)
{
    lbRadialArtifacts.List.Swap(i, x);
    lbRadialArtifacts.List.SetIndex(x);

    bDirty = true;
}

function bool ChangePriority(GUIComponent Sender)
{
    if(lbRadialArtifacts.List.ItemCount > 1)
    {
        if(Sender == btUp && lbRadialArtifacts.List.Index > 0)
            SwapArtifacts(lbRadialArtifacts.List.Index, lbRadialArtifacts.List.Index - 1);
        else if(Sender == btDown && lbRadialArtifacts.List.Index < lbRadialArtifacts.List.ItemCount - 1)
            SwapArtifacts(lbRadialArtifacts.List.Index, lbRadialArtifacts.List.Index + 1);

        bDirty = true;
    }
    return true;
}

function bool ListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectArtifact(lbArtifacts.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool RadialListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectArtifact(lbRadialArtifacts.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool Clicked(GUIComponent Sender)
{
    if(Sender == lbArtifacts)
        SelectArtifact(lbArtifacts.List);
    else if(Sender == lbRadialArtifacts)
        SelectArtifact(lbRadialArtifacts.List);

    return true;
}

function InternalOnChange(GUIComponent Sender)
{
    local int i;
    local bool bShowAll;

    if(bIgnoreNextChange)
        return;

    RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    switch(Sender)
    {
        case chShowAlways:
            AllElements[int(lbRadialArtifacts.List.GetExtra())].bShowAlways = chShowAlways.IsChecked();

            bShowAll = true;
            for(i = 0; i < lbRadialArtifacts.List.Elements.Length; i++)
            {
                bShowAll = bShowAll && AllElements[int(lbRadialArtifacts.List.Elements[i].ExtraStrData)].bShowAlways;
                if(!bShowAll)
                    break;
            }

            bIgnoreNextChange = true;
            chShowAll.Checked(bShowAll);
            bIgnoreNextChange = false;

            bDirty = true;
            break;
        case chEnableRadialMenu:
            RPRI.Interaction.Settings.bEnableArtifactRadialMenu = chEnableRadialMenu.IsChecked();
            break;
        case chShowAll:
            for(i = 0; i < lbRadialArtifacts.List.Elements.Length; i++)
                AllElements[int(lbRadialArtifacts.List.Elements[i].ExtraStrData)].bShowAlways = chShowAll.IsChecked();

            if(chShowAlways.MenuState != MSAT_Disabled)
            {
                bIgnoreNextChange = true;
                chShowAlways.Checked(chShowAll.IsChecked());
                bIgnoreNextChange = false;
            }

            bDirty = true;
            break;
        case slAnimSpeed:
            RPRI.Interaction.Settings.ArtifactRadialMenuAnimSpeed = slAnimSpeed.GetValue();
            break;
        case slMouseSens:
            RPRI.Interaction.Settings.ArtifactRadialMenuMouseSens = slMouseSens.GetValue();
            break;
    }
}

function bool ShowHelp(GUIComponent Sender)
{
    Controller.OpenMenu("TURRPG2.RPGMenu_ArtifactRadialHelpMessageWindow");
    return true;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    local int i;
    local RPGCharSettings Settings;
    local RPGPlayerReplicationInfo.RadialMenuArtifactStruct RadialEntry;
    local RPGCharSettings.ArtifactRadialMenuConfigStruct RadialConfigEntry;

    if(bDirty)
    {
        Settings = RPRI.Interaction.CharSettings;

        Settings.ArtifactRadialMenuConfig.Length = 0;
        RPRI.ArtifactRadialMenuOrder.Length = 0;

        for(i = 0; i < lbRadialArtifacts.List.Elements.Length; i++)
        {
            RadialEntry.ArtifactClass = AllElements[int(lbRadialArtifacts.List.Elements[i].ExtraStrData)].ArtifactClass;
            RadialEntry.ArtifactID = AllElements[int(lbRadialArtifacts.List.Elements[i].ExtraStrData)].ArtifactClass.default.ArtifactID;
            RadialEntry.bShowAlways = AllElements[int(lbRadialArtifacts.List.Elements[i].ExtraStrData)].bShowAlways;
            RPRI.ArtifactRadialMenuOrder[RPRI.ArtifactRadialMenuOrder.Length] = RadialEntry;

            RadialConfigEntry.ArtifactID = AllElements[int(lbRadialArtifacts.List.Elements[i].ExtraStrData)].ArtifactClass.default.ArtifactID;
            RadialConfigEntry.bShowAlways = AllElements[int(lbRadialArtifacts.List.Elements[i].ExtraStrData)].bShowAlways;
            Settings.ArtifactRadialMenuConfig[Settings.ArtifactRadialMenuConfig.Length] = RadialConfigEntry;
        }

        bDirty = false;
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
    Begin Object Class=AltSectionBackground Name=sbArtifacts_
        Caption="Available Artifacts"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.299353
        WinHeight=0.702462
        WinLeft=0.000085
        WinTop=0.032034
        OnPreDraw=sbArtifacts_.InternalPreDraw
    End Object
    sbArtifacts=GUISectionBackground'sbArtifacts_'

    Begin Object Class=AltSectionBackground Name=sbRadialArtifacts_
        Caption="Active Radial Menu Artifacts"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.299353
        WinHeight=0.702462
        WinLeft=0.301193
        WinTop=0.032034
        OnPreDraw=sbRadialArtifacts_.InternalPreDraw
    End Object
    sbRadialArtifacts=GUISectionBackground'sbRadialArtifacts_'

    Begin Object Class=AltSectionBackground Name=sbArtifact_
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.600095
        WinHeight=0.223499
        WinLeft=0.000085
        WinTop=0.736339
        OnPreDraw=sbArtifact_.InternalPreDraw
    End Object
    sbArtifact=GUISectionBackground'sbArtifact_'

    Begin Object Class=AltSectionBackground Name=sbRadial_
        Caption="Radial Menu Preview"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.397189
        WinHeight=0.553438
        WinLeft=0.602841
        WinTop=0.032034
        OnPreDraw=sbRadialArtifacts_.InternalPreDraw
    End Object
    sbRadial=GUISectionBackground'sbRadial_'

    Begin Object Class=AltSectionBackground Name=sbGlobalSettings_
        Caption="Settings"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.397189
        WinHeight=0.374402
        WinLeft=0.602841
        WinTop=0.586143
        OnPreDraw=sbGlobalSettings_.InternalPreDraw
    End Object
    sbGlobalSettings=GUISectionBackground'sbGlobalSettings_'

    Begin Object Class=GUIListBox Name=lbArtifacts_
        WinWidth=0.264595
        WinHeight=0.606651
        WinLeft=0.018702
        WinTop=0.079171
        bVisibleWhenEmpty=true
        Hint="These are the available artifacts."
        StyleName="NoBackground"
    End Object
    lbArtifacts=lbArtifacts_

    Begin Object Class=GUIListBox Name=lbRadialArtifacts_
        WinWidth=0.264595
        WinHeight=0.563249
        WinLeft=0.320352
        WinTop=0.079171
        bVisibleWhenEmpty=true
        Hint="These are the artifacts that will display on the radial menu."
        StyleName="NoBackground"
    End Object
    lbRadialArtifacts=lbRadialArtifacts_

    Begin Object Class=GUIMultiOptionListBox Name=lbSettings_
        WinWidth=0.238553
        WinHeight=0.120541
        WinLeft=0.345309
        WinTop=0.786982
        bBoundToParent=True
        bScaleToParent=True
        bVisibleWhenEmpty=true
        StyleName="NoBackground"
    End Object
    lbSettings=lbSettings_

    Begin Object Class=GUIMultiOptionListBox Name=lbGlobalSettings_
        WinWidth=0.358996
        WinHeight=0.270281
        WinLeft=0.623084
        WinTop=0.637621
        bBoundToParent=True
        bScaleToParent=True
        bVisibleWhenEmpty=true
        StyleName="NoBackground"
    End Object
    lbGlobalSettings=lbGlobalSettings_

    Begin Object Class=GUIGFXButton Name=btAdd_
        Hint="Add the selected artifact to the radial menu."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.313905
        OnClick=AddArtifact
        OnClickSound=CS_Up
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=3
    End Object
    btAdd=btAdd_

    Begin Object Class=GUIGFXButton Name=btRemove_
        Hint="Remove the selected artifact from the radial menu."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.358754
        OnClick=RemoveArtifact
        OnClickSound=CS_Down
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=2
    End Object
    btRemove=btRemove_

    Begin Object Class=GUIGFXButton Name=btUp_
        Hint="Move artifact counter-clockwise in the radial menu."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.412940
        WinTop=0.645214
        OnClick=ChangePriority
        OnClickSound=CS_Up
        StyleName="AltComboButton"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=6
    End Object
    btUp=btUp_

    Begin Object Class=GUIGFXButton Name=btDown_
        Hint="Move artifact clockwise in the radial menu."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.446347
        WinTop=0.645214
        OnClick=ChangePriority
        OnClickSound=CS_Down
        StyleName="ComboButton"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=7
    End Object
    btDown=btDown_

    Begin Object Class=GUIScrollTextBox Name=lbDesc_
        WinWidth=0.217968
        WinHeight=0.120794
        WinLeft=0.112506
        WinTop=0.786982
        CharDelay=0.001250
        EOLDelay=0.001250
        bNeverFocus=true
        bAcceptsInput=false
        bVisibleWhenEmpty=True
        FontScale=FNS_Small
        StyleName="NoBackground"
    End Object
    lbDesc=lbDesc_

    Begin Object class=GUIImage Name=imIcon_
        WinWidth=0.079098
        WinHeight=0.120794
        WinLeft=0.017940
        WinTop=0.786982
        X1=0
        Y1=0
        X2=64
        Y2=64
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageRenderStyle=MSTY_Alpha
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_TopLeft
    End Object
    imIcon=imIcon_

    Begin Object Class=GUIButton Name=btHelp_
        Caption="?"
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.948723
        WinTop=0.078083
        bBoundToParent=True
        bScaleToParent=True
        OnClick=RPGMenu_ArtifactRadialWindow.ShowHelp
    End Object
    btHelp=btHelp_

    bResizeWidthAllowed=False
    bResizeHeightAllowed=False
    bMoveAllowed=False
    bPersistent=True
    bAllowedAsLast=True
    bAcceptsInput=False
    bCaptureInput=True

    WinLeft=0.05
    WinTop=0.05
    WinWidth=0.90
    WinHeight=0.90

    Text_HintShowAlways="Always show this artifact on the radial menu, even if you do not have it in your inventory."

    Text_HintEnableRadialMenu="Enable the artifact radial menu."
    Text_HintShowAll="Quickly toggles Show always for all artifacts."
    Text_HintAnimSpeed="Animation speed for the radial menu."
    Text_HintMouseSens="Multiplier for the mouse sensitivity on the radial menu. A value of 1 will use only the configured mouse sensitivity for other menus."
    Text_HintHelp="Show the help message."

    WindowTitle="Artifact Radial Menu Configuration"
    NotAvailableText="N/A:"
    NotAvailableTitle="N/A"
    NotAvailableDesc="This artifact is not available on this server."
}
