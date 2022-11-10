//=============================================================================
// RPGMenu_ArtificersWorkbenchWindow.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMenu_ArtificersWorkbenchWindow extends FloatingWindow
    DependsOn(RPGCharSettings);

var RPGPlayerReplicationInfo RPRI;
var bool bDirty;
var bool bIgnoreNextChange;

var automated GUISectionBackground sbModifierPool, sbListCharmA, sbListCharmB,
                                   sbListCharmC, sbSettings, sbDescription;
var automated GUIListBox lbAugmentPool, lbCharmA, lbCharmB, lbCharmC;
var automated GUIGFXButton btAddCharmA, btRemoveCharmA;
var automated GUIGFXButton btAddCharmB, btRemoveCharmB;
var automated GUIGFXButton btAddCharmC, btRemoveCharmC;
var automated GUIComboBox cmbAutoApplyAlpha, cmbAutoApplyBeta, cmbAutoApplyGamma;
var automated GUILabel lblAutoApplyAlpha, lblAutoApplyBeta, lblAutoApplyGamma;
var automated GUIImage imIcon;
var automated GUIScrollTextBox lbDesc;
var automated GUIButton btHelp;

var class<Weapon> OldAutoApplyWeaponAlpha, OldAutoApplyWeaponBeta, OldAutoApplyWeaponGamma;
var array<GUIListElem> AutoApplyAlphaList, AutoApplyBetaList, AutoApplyGammaList;

var GUIList LastInteractedList; //list which we were last interacting with
                                //which isn't the modifier pool

var localized string WindowTitle;

var localized string Text_HintHelp;

var localized string Text_NoAutoApply;

var localized string Text_AutoApplyAlpha;
var localized string Text_AutoApplyBeta;
var localized string Text_AutoApplyGamma;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    lbAugmentPool.List.bInitializeList = false;
    lbAugmentPool.List.bDropSource = true;
    lbAugmentPool.List.bDropTarget = true;
    lbAugmentPool.List.bMultiSelect = true;
    lbAugmentPool.List.bSorted = true;

    lbCharmA.List.bInitializeList = false;
    lbCharmA.List.bDropSource = true;
    lbCharmA.List.bDropTarget = true;
    lbCharmA.List.bMultiSelect = true;
    lbCharmA.List.bSorted = true;

    lbCharmB.List.bInitializeList = false;
    lbCharmB.List.bDropSource = true;
    lbCharmB.List.bDropTarget = true;
    lbCharmB.List.bMultiSelect = true;
    lbCharmB.List.bSorted = true;

    lbCharmC.List.bInitializeList = false;
    lbCharmC.List.bDropSource = true;
    lbCharmC.List.bDropTarget = true;
    lbCharmC.List.bMultiSelect = true;
    lbCharmC.List.bSorted = true;

    lbAugmentPool.List.CheckLinkedObjects = InternalCheckObjects;
    lbAugmentPool.List.AddLinkObject(btAddCharmA, true);
    lbAugmentPool.List.AddLinkObject(btAddCharmB, true);
    lbAugmentPool.List.AddLinkObject(btAddCharmC, true);

    lbCharmA.List.CheckLinkedObjects = InternalCheckObjects;
    lbCharmA.List.AddLinkObject(btRemoveCharmA, true);

    lbCharmB.List.CheckLinkedObjects = InternalCheckObjects;
    lbCharmB.List.AddLinkObject(btRemoveCharmB, true);

    lbCharmC.List.CheckLinkedObjects = InternalCheckObjects;
    lbCharmC.List.AddLinkObject(btRemoveCharmC, true);

    lbAugmentPool.List.DisableLinkedObjects();
    lbCharmA.List.DisableLinkedObjects();
    lbCharmB.List.DisableLinkedObjects();
    lbCharmC.List.DisableLinkedObjects();
    InternalCheckObjects(None);

    lbAugmentPool.OnClick = InternalOnClick;
    lbCharmA.OnClick = InternalOnClick;
    lbCharmB.OnClick = InternalOnClick;
    lbCharmC.OnClick = InternalOnClick;

    lbAugmentPool.OnKeyEvent = ListKeyEvent;
    lbCharmA.OnKeyEvent = CharmAListKeyEvent;
    lbCharmB.OnKeyEvent = CharmBListKeyEvent;
    lbCharmC.OnKeyEvent = CharmCListKeyEvent;

    lbAugmentPool.List.OnDragDrop = InternalOnDragDrop;
    lbCharmA.List.OnDragDrop = InternalOnDragDrop;
    lbCharmB.List.OnDragDrop = InternalOnDragDrop;
    lbCharmC.List.OnDragDrop = InternalOnDragDrop;

    lbAugmentPool.List.OnDblClick = AddModifier;
    lbCharmA.List.OnDblClick = RemoveModifier;
    lbCharmB.List.OnDblClick = RemoveModifier;
    lbCharmC.List.OnDblClick = RemoveModifier;

    lbAugmentPool.List.OnDrawItem = InternalDrawPoolItem;
    lbCharmA.List.OnDrawItem = InternalDrawCharmAItem;
    lbCharmB.List.OnDrawItem = InternalDrawCharmBItem;
    lbCharmC.List.OnDrawItem = InternalDrawCharmCItem;

    cmbAutoApplyAlpha.Edit.bReadOnly = true;
    cmbAutoApplyAlpha.List.bInitializeList = false;
    cmbAutoApplyAlpha.List.bSorted = true;

    cmbAutoApplyBeta.Edit.bReadOnly = true;
    cmbAutoApplyBeta.List.bInitializeList = false;
    cmbAutoApplyBeta.List.bSorted = true;

    cmbAutoApplyGamma.Edit.bReadOnly = true;
    cmbAutoApplyGamma.List.bInitializeList = false;
    cmbAutoApplyGamma.List.bSorted = true;

    t_WindowTitle.SetCaption(WindowTitle);
    btHelp.ToolTip.SetTip(Text_HintHelp);

    lblAutoApplyAlpha.Caption = Text_AutoApplyAlpha;
    lblAutoApplyBeta.Caption = Text_AutoApplyBeta;
    lblAutoApplyGamma.Caption = Text_AutoApplyGamma;
}

function InitFor(RPGPlayerReplicationInfo Whom)
{
    local int i, x;
    local Ability_LoadedAugments Ability;
    local class<ArtificerAugmentBase> MClass;
    local RPGCharSettings Settings;

    RPRI = Whom;
    Settings = RPRI.Interaction.CharSettings;

    lbAugmentPool.List.bNotify = false;
    lbCharmA.List.bNotify = false;
    lbCharmB.List.bNotify = false;
    lbCharmC.List.bNotify = false;

    lbAugmentPool.List.Clear();
    lbCharmA.List.Clear();
    lbCharmB.List.Clear();
    lbCharmC.List.Clear();

    Ability = Ability_LoadedAugments(RPRI.GetOwnedAbility(class'Ability_LoadedAugments'));
    if(Ability == None)
    {
        lbAugmentPool.DisableMe();
        lbCharmA.DisableMe();
        lbCharmB.DisableMe();
        lbCharmC.DisableMe();
        return;
    }
    else
    {
        lbAugmentPool.EnableMe();
        lbCharmA.EnableMe();
        lbCharmB.EnableMe();
        lbCharmC.EnableMe();
    }

    //populate the entire pool
    for(i = 0; i < Ability.GrantedAugments.Length; i++)
    {
        MClass = Ability.GrantedAugments[i].AugmentClass;
        for(x = 0; x < Ability.GrantedAugments[i].Amount; x++)
            lbAugmentPool.List.Add(MClass.default.ModifierName, MClass);
    }

    //populate the charm lists and subtract those augments from the pool
    PackCharmList(lbCharmA.List, Settings.ArtificerCharmAlphaConfig);
    PackCharmList(lbCharmB.List, Settings.ArtificerCharmBetaConfig);
    PackCharmList(lbCharmC.List, Settings.ArtificerCharmGammaConfig);

    lbAugmentPool.List.bNotify = true;
    lbCharmA.List.bNotify = true;
    lbCharmB.List.bNotify = true;
    lbCharmC.List.bNotify = true;

    lbAugmentPool.List.SilentSetIndex(0);
    lbCharmA.List.SilentSetIndex(0);
    lbCharmB.List.SilentSetIndex(0);
    lbCharmC.List.SilentSetIndex(0);
    SelectModifier();

    //populate the auto-apply combo boxes
    cmbAutoApplyAlpha.List.bNotify = false;
    cmbAutoApplyBeta.List.bNotify = false;
    cmbAutoApplyGamma.List.bNotify = false;

    cmbAutoApplyAlpha.List.Elements.Length = 0;
    cmbAutoApplyBeta.List.Elements.Length = 0;
    cmbAutoApplyGamma.List.Elements.Length = 0;

    //TODO make this dynamic
    for(i = 0; i < class'Ability_LoadedWeapons'.default.GrantItem.Length; i++)
    {
        cmbAutoApplyAlpha.AddItem(
            class'Ability_LoadedWeapons'.default.GrantItem[i].InventoryClass.default.ItemName,
            class'Ability_LoadedWeapons'.default.GrantItem[i].InventoryClass);
        cmbAutoApplyBeta.AddItem(
            class'Ability_LoadedWeapons'.default.GrantItem[i].InventoryClass.default.ItemName,
            class'Ability_LoadedWeapons'.default.GrantItem[i].InventoryClass);
        cmbAutoApplyGamma.AddItem(
            class'Ability_LoadedWeapons'.default.GrantItem[i].InventoryClass.default.ItemName,
            class'Ability_LoadedWeapons'.default.GrantItem[i].InventoryClass);
    }

    cmbAutoApplyAlpha.List.Sort();
    cmbAutoApplyBeta.List.Sort();
    cmbAutoApplyGamma.List.Sort();

    //no auto apply option inserted manually after sorting
    AutoApplyAlphaList = cmbAutoApplyAlpha.List.Elements;
    AutoApplyBetaList = cmbAutoApplyBeta.List.Elements;
    AutoApplyGammaList = cmbAutoApplyGamma.List.Elements;

    cmbAutoApplyAlpha.List.Insert(0, Text_NoAutoApply,,, true);
    cmbAutoApplyBeta.List.Insert(0, Text_NoAutoApply,,, true);
    cmbAutoApplyGamma.List.Insert(0, Text_NoAutoApply,,, true);

    cmbAutoApplyAlpha.List.bNotify = true;
    cmbAutoApplyBeta.List.bNotify = true;
    cmbAutoApplyGamma.List.bNotify = true;

    //now load auto-apply from settings
    if(Settings.ArtificerAutoApplyWeaponAlpha != None)
        cmbAutoApplyAlpha.SetIndex(cmbAutoApplyAlpha.FindIndex(Settings.ArtificerAutoApplyWeaponAlpha.default.ItemName));
    else
        cmbAutoApplyAlpha.SetIndex(0);

    if(Settings.ArtificerAutoApplyWeaponBeta != None
        && Settings.ArtificerAutoApplyWeaponBeta != Settings.ArtificerAutoApplyWeaponAlpha
    )
        cmbAutoApplyBeta.SetIndex(cmbAutoApplyBeta.FindIndex(Settings.ArtificerAutoApplyWeaponBeta.default.ItemName));
    else
        cmbAutoApplyBeta.SetIndex(0);

    if(Settings.ArtificerAutoApplyWeaponGamma != None
        && Settings.ArtificerAutoApplyWeaponGamma != Settings.ArtificerAutoApplyWeaponAlpha
        && Settings.ArtificerAutoApplyWeaponGamma != Settings.ArtificerAutoApplyWeaponBeta
    )
        cmbAutoApplyGamma.SetIndex(cmbAutoApplyGamma.FindIndex(Settings.ArtificerAutoApplyWeaponGamma.default.ItemName));
    else
        cmbAutoApplyGamma.SetIndex(0);
}

function SelectModifier(optional GUIList List)
{
    local class<ArtificerAugmentBase> MClass;

    RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    if(List == None)
        List = lbAugmentPool.List;

    MClass = class<ArtificerAugmentBase>(List.GetObject());
    if(MClass != None)
    {
        sbDescription.Caption = MClass.default.ModifierName;
        lbDesc.SetContent(MClass.static.StaticGetDescription());

        imIcon.Image = Texture(MClass.default.IconMaterial);
        imIcon.X2 = imIcon.Image.MaterialUSize();
        imIcon.Y2 = imIcon.Image.MaterialVSize();
        imIcon.SetVisibility(true);
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

    if(lbAugmentPool.List.ItemCount > 0)
    {
        EnableComponent(btAddCharmA);
        EnableComponent(btAddCharmB);
        EnableComponent(btAddCharmC);
    }
    else
    {
        DisableComponent(btAddCharmA);
        DisableComponent(btAddCharmB);
        DisableComponent(btAddCharmC);
    }

    if(lbCharmA.List.ItemCount > 0)
        EnableComponent(btRemoveCharmA);
    else
        DisableComponent(btRemoveCharmA);

    if(lbCharmB.List.ItemCount > 0)
        EnableComponent(btRemoveCharmB);
    else
        DisableComponent(btRemoveCharmB);

    if(lbCharmC.List.ItemCount > 0)
        EnableComponent(btRemoveCharmC);
    else
        DisableComponent(btRemoveCharmC);
}

function ListChange(GUIComponent Sender)
{
    switch(Sender)
    {
        case lbAugmentPool:
            lbAugmentPool.List.SilentSetIndex(-1);
            InternalCheckObjects(lbAugmentPool.List);
            break;
        case lbCharmA:
            lbCharmA.List.SilentSetIndex(-1);
            InternalCheckObjects(lbCharmA.List);
            break;
        case lbCharmB:
            lbCharmB.List.SilentSetIndex(-1);
            InternalCheckObjects(lbCharmB.List);
            break;
        case lbCharmC:
            lbCharmC.List.SilentSetIndex(-1);
            InternalCheckObjects(lbCharmC.List);
            break;
        default:
            break;
    }
}

function bool AddModifier(GUIComponent Sender)
{
    local array<GUIListElem> PendingElements;
    local GUIList Target;
    local int i;

    if(!lbAugmentPool.List.IsValid())
        return true;

    //default to charm A's list if we don't have one last interacted with
    if(Sender == lbAugmentPool.List && LastInteractedList == None)
        LastInteractedList = lbCharmA.List;

    switch(Sender)
    {
        case btAddCharmA:
            Target = lbCharmA.List;
            break;
        case btAddCharmB:
            Target = lbCharmB.List;
            break;
        case btAddCharmC:
            Target = lbCharmC.List;
            break;
        case lbAugmentPool.List:
            Target = LastInteractedList;
            break;
    }

    PendingElements = lbAugmentPool.List.GetPendingElements(true);

    lbAugmentPool.List.bNotify = false;
    for(i = PendingElements.Length - 1; i >= 0; i--)
    {
        lbAugmentPool.List.RemoveElement(PendingElements[i],, true);
        Target.AddElement(PendingElements[i]);
    }

    lbAugmentPool.List.bNotify = true;
    lbAugmentPool.List.ClearPendingElements();
    lbAugmentPool.List.SetIndex(lbAugmentPool.List.Index); //to check if button states should change

    lbAugmentPool.List.Sort();

    Target.Sort();

    bDirty = true;

    return true;
}

function bool RemoveModifier(GUIComponent Sender)
{
    local array<GUIListElem> PendingElements;
    local int i;
    local GUIList List;

    switch(Sender)
    {
        case btRemoveCharmA:
        case lbCharmA.List:
            List = lbCharmA.List;
            break;
        case btRemoveCharmB:
        case lbCharmB.List:
            List = lbCharmB.List;
            break;
        case btRemoveCharmC:
        case lbCharmC.List:
            List = lbCharmC.List;
            break;
    }

    if(!List.IsValid())
        return true;

    PendingElements = List.GetPendingElements(true);
    List.bNotify = false;
    for(i = PendingElements.Length - 1; i >= 0; i--)
    {
        List.RemoveElement(PendingElements[i],, true);
        lbAugmentPool.List.AddElement(PendingElements[i]);
    }

    List.bNotify = true;
    List.ClearPendingElements();

    bDirty = true;

    return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
    switch(Sender)
    {
        case lbCharmA:
        case lbCharmB:
        case lbCharmC:
            SelectModifier(GUIListBox(Sender).List);
            LastInteractedList = GUIListBox(Sender).List;
            return true;
        case lbAugmentPool:
            SelectModifier(GUIListBox(Sender).List);
            return true;
        case btAddCharmA:
            LastInteractedList = lbCharmA.List;
            return AddModifier(Sender);
        case btAddCharmB:
            LastInteractedList = lbCharmB.List;
            return AddModifier(Sender);
        case btAddCharmC:
            LastInteractedList = lbCharmC.List;
            return AddModifier(Sender);
    }
    return true;
}

function bool InternalOnDragDrop(GUIComponent Target)
{
    local GUIList Source;
    local array<GUIListElem> PendingElements;
    local int i;

    if(Controller == None)
        return false;

    Source = GUIList(Controller.DropSource);
    if(Source == None || Source == Target)
        return false;

    if(!Source.IsValid())
        return false;

    PendingElements = Source.GetPendingElements(true);
    Source.bNotify = false;
    for(i = PendingElements.Length - 1; i >= 0; i--)
    {
        Source.RemoveElement(PendingElements[i],, true);
        GUIList(Target).AddElement(PendingElements[i]);
    }
    Source.bNotify = true;
    Source.ClearPendingElements();
    Source.SetIndex(Source.Index); //to check if button states should change

    Source.Sort();
    GUIList(Target).Sort();

    bDirty = true;

    return false;
}

function bool ListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectModifier(lbAugmentPool.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool CharmAListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectModifier(lbCharmA.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool CharmBListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectModifier(lbCharmB.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool CharmCListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectModifier(lbCharmC.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool Clicked(GUIComponent Sender)
{
    switch(Sender)
    {
        case lbAugmentPool:
            SelectModifier(lbAugmentPool.List);
            break;
        case lbCharmA:
            SelectModifier(lbCharmA.List);
            break;
        case lbCharmB:
            SelectModifier(lbCharmB.List);
            break;
        case lbCharmC:
            SelectModifier(lbCharmC.List);
            break;
        default:
            break;
    }

    return true;
}

function InternalDrawPoolItem(Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    DrawListItem(lbAugmentPool.List, C, Item, X, Y, W, H, bSelected, bPending);
}

function InternalDrawCharmAItem(Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    DrawListItem(lbCharmA.List, C, Item, X, Y, W, H, bSelected, bPending);
}

function InternalDrawCharmBItem(Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    DrawListItem(lbCharmB.List, C, Item, X, Y, W, H, bSelected, bPending);
}

function InternalDrawCharmCItem(Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    DrawListItem(lbCharmC.List, C, Item, X, Y, W, H, bSelected, bPending);
}

function DrawListItem(GUIList List, Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local GUIStyles DStyle;
    local float XL, YL;
    local class<ArtificerAugmentBase> Augment;

    if(bSelected)
        DStyle = List.SelectedStyle;
    else
        DStyle = List.Style;
    DStyle.Draw(C, List.MenuState, X, Y, W, H);

    DStyle.DrawText(C, List.MenuState, X, Y, W, H, TXTA_Center, List.GetItemAtIndex(Item), List.FontScale);

    //draw icon next to item
    Augment = class<ArtificerAugmentBase>(List.GetObjectAtIndex(Item));
    if(Augment.default.IconMaterial != None)
    {
        DStyle.TextSize(C, List.MenuState, List.GetItemAtIndex(Item), XL, YL, List.FontScale);
        C.SetPos(X + (W * 0.5) - (XL * 0.5) - H * 1.5, Y);
        C.Style = 5; //STY_Alpha
        C.DrawColor = C.MakeColor(255, 255, 255);
        C.DrawTile(Augment.default.IconMaterial, H, H, 0, 0, Augment.default.IconMaterial.MaterialUSize(), Augment.default.IconMaterial.MaterialVSize());
    }
}

function InternalOnChange(GUIComponent Sender)
{
    RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something
}

function bool ShowHelp(GUIComponent Sender)
{
    Controller.OpenMenu("TURRPG2.RPGMenu_ArtificersWorkbenchHelpMessageWindow");
    return true;
}

final function PackCharmList(GUIList List, array<RPGCharSettings.ArtificerAugmentStruct> Augments)
{
    local int i, x, y;
    local class<ArtificerAugmentBase> MClass;

    for(i = 0; i < Augments.Length; i++)
    {
        MClass = Augments[i].AugmentClass;
        for(x = 0; x < Augments[i].ModifierLevel; x++)
        {
            List.Add(MClass.default.ModifierName, MClass);

            y = lbAugmentPool.List.FindItemObject(MClass);
            if(y != -1)
                lbAugmentPool.List.Remove(y,, true);
        }
    }
}

final function UnpackCharmList(GUIList List, out array<RPGCharSettings.ArtificerAugmentStruct> Augments)
{
    local int i, x;

    for(i = 0; i < List.ItemCount; i++)
    {
        for(x = 0; x < Augments.Length; x++)
        {
            if(Augments[x].AugmentClass == List.Elements[i].ExtraData)
            {
                Augments[x].ModifierLevel++;
                x = -1;
                break;
            }
        }
        if(x == -1)
            continue;

        x = Augments.Length;
        Augments.Length = x + 1;
        Augments[x].AugmentClass = class<ArtificerAugmentBase>(List.Elements[i].ExtraData);
        Augments[x].ModifierLevel = 1;
    }
}

function AutoApplySelected(GUIComponent Sender)
{
    local GUIListElem Elem;
    local int i;

    switch(Sender)
    {
        case cmbAutoApplyAlpha:
            bDirty = true;
            cmbAutoApplyBeta.List.bNotify = false;
            cmbAutoApplyGamma.List.bNotify = false;
            if(OldAutoApplyWeaponAlpha != None)
            {
                Elem.Item = OldAutoApplyWeaponAlpha.default.ItemName;
                Elem.ExtraData = OldAutoApplyWeaponAlpha;

                AutoApplyBetaList[AutoApplyBetaList.Length] = Elem;
                AutoApplyGammaList[AutoApplyGammaList.Length] = Elem;

                cmbAutoApplyBeta.List.Elements = AutoApplyBetaList;
                cmbAutoApplyGamma.List.Elements = AutoApplyGammaList;

                cmbAutoApplyBeta.List.Sort();
                cmbAutoApplyGamma.List.Sort();

                cmbAutoApplyBeta.List.Insert(0, Text_NoAutoApply,,, true);
                cmbAutoApplyGamma.List.Insert(0, Text_NoAutoApply,,, true);
            }
            if(cmbAutoApplyAlpha.GetObject() != None)
            {
                for(i = 0; i < AutoApplyBetaList.Length; i++)
                {
                    if(AutoApplyBetaList[i] == cmbAutoApplyAlpha.List.Elements[cmbAutoApplyAlpha.List.Index])
                    {
                        AutoApplyBetaList.Remove(i, 1);
                        break;
                    }
                }
                for(i = 0; i < AutoApplyGammaList.Length; i++)
                {
                    if(AutoApplyGammaList[i] == cmbAutoApplyAlpha.List.Elements[cmbAutoApplyAlpha.List.Index])
                    {
                        AutoApplyGammaList.Remove(i, 1);
                        break;
                    }
                }

                cmbAutoApplyBeta.List.Elements = AutoApplyBetaList;
                cmbAutoApplyGamma.List.Elements = AutoApplyGammaList;

                cmbAutoApplyBeta.List.Insert(0, Text_NoAutoApply,,, true);
                cmbAutoApplyGamma.List.Insert(0, Text_NoAutoApply,,, true);
            }
            cmbAutoApplyBeta.List.bNotify = true;
            cmbAutoApplyGamma.List.bNotify = true;
            OldAutoApplyWeaponAlpha = class<Weapon>(cmbAutoApplyAlpha.GetObject());
            break;
        case cmbAutoApplyBeta:
            bDirty = true;
            cmbAutoApplyAlpha.List.bNotify = false;
            cmbAutoApplyGamma.List.bNotify = false;
            if(OldAutoApplyWeaponBeta != None)
            {
                Elem.Item = OldAutoApplyWeaponBeta.default.ItemName;
                Elem.ExtraData = OldAutoApplyWeaponBeta;

                AutoApplyAlphaList[AutoApplyAlphaList.Length] = Elem;
                AutoApplyGammaList[AutoApplyGammaList.Length] = Elem;

                cmbAutoApplyAlpha.List.Elements = AutoApplyAlphaList;
                cmbAutoApplyGamma.List.Elements = AutoApplyGammaList;

                cmbAutoApplyAlpha.List.Sort();
                cmbAutoApplyGamma.List.Sort();

                cmbAutoApplyAlpha.List.Insert(0, Text_NoAutoApply,,, true);
                cmbAutoApplyGamma.List.Insert(0, Text_NoAutoApply,,, true);
            }
            if(cmbAutoApplyBeta.GetObject() != None)
            {
                for(i = 0; i < AutoApplyAlphaList.Length; i++)
                {
                    if(AutoApplyAlphaList[i] == cmbAutoApplyBeta.List.Elements[cmbAutoApplyBeta.List.Index])
                    {
                        AutoApplyAlphaList.Remove(i, 1);
                        break;
                    }
                }
                for(i = 0; i < AutoApplyGammaList.Length; i++)
                {
                    if(AutoApplyGammaList[i] == cmbAutoApplyBeta.List.Elements[cmbAutoApplyBeta.List.Index])
                    {
                        AutoApplyGammaList.Remove(i, 1);
                        break;
                    }
                }

                cmbAutoApplyAlpha.List.Elements = AutoApplyAlphaList;
                cmbAutoApplyGamma.List.Elements = AutoApplyGammaList;

                cmbAutoApplyAlpha.List.Insert(0, Text_NoAutoApply,,, true);
                cmbAutoApplyGamma.List.Insert(0, Text_NoAutoApply,,, true);
            }
            cmbAutoApplyAlpha.List.bNotify = true;
            cmbAutoApplyGamma.List.bNotify = true;
            OldAutoApplyWeaponBeta = class<Weapon>(cmbAutoApplyBeta.GetObject());
            break;
        case cmbAutoApplyGamma:
            bDirty = true;
            cmbAutoApplyAlpha.List.bNotify = false;
            cmbAutoApplyBeta.List.bNotify = false;
            if(OldAutoApplyWeaponGamma != None)
            {
                Elem.Item = OldAutoApplyWeaponGamma.default.ItemName;
                Elem.ExtraData = OldAutoApplyWeaponGamma;

                AutoApplyAlphaList[AutoApplyAlphaList.Length] = Elem;
                AutoApplyBetaList[AutoApplyBetaList.Length] = Elem;

                cmbAutoApplyAlpha.List.Elements = AutoApplyAlphaList;
                cmbAutoApplyBeta.List.Elements = AutoApplyBetaList;

                cmbAutoApplyAlpha.List.Sort();
                cmbAutoApplyBeta.List.Sort();

                cmbAutoApplyAlpha.List.Insert(0, Text_NoAutoApply,,, true);
                cmbAutoApplyBeta.List.Insert(0, Text_NoAutoApply,,, true);
            }
            if(cmbAutoApplyGamma.GetObject() != None)
            {
                for(i = 0; i < AutoApplyAlphaList.Length; i++)
                {
                    if(AutoApplyAlphaList[i] == cmbAutoApplyGamma.List.Elements[cmbAutoApplyGamma.List.Index])
                    {
                        AutoApplyAlphaList.Remove(i, 1);
                        break;
                    }
                }
                for(i = 0; i < AutoApplyBetaList.Length; i++)
                {
                    if(AutoApplyBetaList[i] == cmbAutoApplyGamma.List.Elements[cmbAutoApplyGamma.List.Index])
                    {
                        AutoApplyBetaList.Remove(i, 1);
                        break;
                    }
                }

                cmbAutoApplyAlpha.List.Elements = AutoApplyAlphaList;
                cmbAutoApplyBeta.List.Elements = AutoApplyBetaList;

                cmbAutoApplyAlpha.List.Insert(0, Text_NoAutoApply,,, true);
                cmbAutoApplyBeta.List.Insert(0, Text_NoAutoApply,,, true);
            }
            cmbAutoApplyAlpha.List.bNotify = true;
            cmbAutoApplyBeta.List.bNotify = true;
            OldAutoApplyWeaponGamma = class<Weapon>(cmbAutoApplyGamma.GetObject());
            break;
    }
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    local RPGCharSettings Settings;
    local array<RPGCharSettings.ArtificerAugmentStruct> Augments;

    if(bDirty)
    {
        Settings = RPRI.Interaction.CharSettings;

        UnpackCharmList(lbCharmA.List, Augments);
        Settings.ArtificerCharmAlphaConfig = Augments;
        RPRI.ArtificerAugmentsAlpha = Augments;
        RPRI.ResendArtificerAugments(0);

        Augments.Length = 0;
        UnpackCharmList(lbCharmB.List, Augments);
        Settings.ArtificerCharmBetaConfig = Augments;
        RPRI.ArtificerAugmentsBeta = Augments;
        RPRI.ResendArtificerAugments(1);

        Augments.Length = 0;
        UnpackCharmList(lbCharmC.List, Augments);
        Settings.ArtificerCharmGammaConfig = Augments;
        RPRI.ArtificerAugmentsGamma = Augments;
        RPRI.ResendArtificerAugments(2);

        Settings.ArtificerAutoApplyWeaponAlpha = class<Weapon>(cmbAutoApplyAlpha.GetObject());
        Settings.ArtificerAutoApplyWeaponBeta = class<Weapon>(cmbAutoApplyBeta.GetObject());
        Settings.ArtificerAutoApplyWeaponGamma = class<Weapon>(cmbAutoApplyGamma.GetObject());
        RPRI.ResendArtificerAutoApplyWeapons();

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
    Begin Object Class=AltSectionBackground Name=sbModifierPool_
        Caption="Available Augments"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.299353
        WinHeight=0.939151
        WinLeft=0.000085
        WinTop=0.032034
        OnPreDraw=sbModifierPool_.InternalPreDraw
    End Object
    sbModifierPool=GUISectionBackground'sbModifierPool_'

    Begin Object Class=AltSectionBackground Name=sbListCharmA_
        Caption="Active Augments on Charm Alpha"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.391367
        WinHeight=0.311574
        WinLeft=0.301193
        WinTop=0.032034
        OnPreDraw=sbListCharmA_.InternalPreDraw
    End Object
    sbListCharmA=GUISectionBackground'sbListCharmA_'

    Begin Object Class=AltSectionBackground Name=sbListCharmB_
        Caption="Active Augments on Charm Beta"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.391367
        WinHeight=0.311574
        WinLeft=0.301193
        WinTop=0.345820
        OnPreDraw=sbListCharmB_.InternalPreDraw
    End Object
    sbListCharmB=GUISectionBackground'sbListCharmB_'

    Begin Object Class=AltSectionBackground Name=sbListCharmC_
        Caption="Active Augments on Charm Gamma"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.391367
        WinHeight=0.311574
        WinLeft=0.301193
        WinTop=0.660469
        OnPreDraw=sbListCharmC_.InternalPreDraw
    End Object
    sbListCharmC=GUISectionBackground'sbListCharmC_'

    Begin Object Class=AltSectionBackground Name=sbDescription_
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.305175
        WinHeight=0.383878
        WinLeft=0.694855
        WinTop=0.032034
        OnPreDraw=sbDescription_.InternalPreDraw
    End Object
    sbDescription=GUISectionBackground'sbDescription_'

    Begin Object Class=AltSectionBackground Name=sbSettings_
        Caption="Settings"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.305175
        WinHeight=0.554017
        WinLeft=0.694855
        WinTop=0.417836
        OnPreDraw=sbSettings_.InternalPreDraw
    End Object
    sbSettings=GUISectionBackground'sbSettings_'

    Begin Object Class=GUIListBox Name=lbAugmentPool_
        WinWidth=0.264595
        WinHeight=0.846233
        WinLeft=0.018702
        WinTop=0.079171
        bVisibleWhenEmpty=true
        Hint="These are the available augments."
        StyleName="NoBackground"
    End Object
    lbAugmentPool=lbAugmentPool_

    Begin Object Class=GUIListBox Name=lbCharmA_
        WinWidth=0.264595
        WinHeight=0.225865
        WinLeft=0.316734
        WinTop=0.075056
        bVisibleWhenEmpty=true
        Hint="These are the augments active on Charm Alpha."
        StyleName="NoBackground"
    End Object
    lbCharmA=lbCharmA_

    Begin Object Class=GUIListBox Name=lbCharmB_
        WinWidth=0.264595
        WinHeight=0.225865
        WinLeft=0.316734
        WinTop=0.388416
        bVisibleWhenEmpty=true
        Hint="These are the augments active on Charm Beta."
        StyleName="NoBackground"
    End Object
    lbCharmB=lbCharmB_

    Begin Object Class=GUIListBox Name=lbCharmC_
        WinWidth=0.264595
        WinHeight=0.225865
        WinLeft=0.316734
        WinTop=0.703662
        bVisibleWhenEmpty=true
        Hint="These are the augments active on Charm Gamma."
        StyleName="NoBackground"
    End Object
    lbCharmC=lbCharmC_

    Begin Object Class=GUIGFXButton Name=btAddCharmA_
        Hint="Add the selected augment to Charm Alpha."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.141066
        OnClick=InternalOnClick
        OnClickSound=CS_Up
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=3
    End Object
    btAddCharmA=btAddCharmA_

    Begin Object Class=GUIGFXButton Name=btRemoveCharmA_
        Hint="Remove the selected augment from Charm Alpha."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.185915
        OnClick=RemoveModifier
        OnClickSound=CS_Down
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=2
    End Object
    btRemoveCharmA=btRemoveCharmA_

    Begin Object Class=GUIGFXButton Name=btAddCharmB_
        Hint="Add the selected augment to Charm Beta."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.454851
        OnClick=InternalOnClick
        OnClickSound=CS_Up
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=3
    End Object
    btAddCharmB=btAddCharmB_

    Begin Object Class=GUIGFXButton Name=btRemoveCharmB_
        Hint="Remove the selected augment from Charm Beta."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.499700
        OnClick=RemoveModifier
        OnClickSound=CS_Down
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=2
    End Object
    btRemoveCharmB=btRemoveCharmB_

    Begin Object Class=GUIGFXButton Name=btAddCharmC_
        Hint="Add the selected augment to Charm Gamma."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.772760
        OnClick=InternalOnClick
        OnClickSound=CS_Up
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=3
    End Object
    btAddCharmC=btAddCharmC_

    Begin Object Class=GUIGFXButton Name=btRemoveCharmC_
        Hint="Remove the selected augment from Charm Gamma."
        WinWidth=0.034507
        WinHeight=0.045850
        WinLeft=0.282731
        WinTop=0.817611
        OnClick=RemoveModifier
        OnClickSound=CS_Down
        StyleName="EditBox"
        bAcceptsInput=True
        Position=ICP_Scaled
        bNeverFocus=true
        bCaptureMouse=true
        bRepeatClick=True
        ImageIndex=2
    End Object
    btRemoveCharmC=btRemoveCharmC_

    Begin Object class=GUIComboBox Name=cmbAutoApplyAlpha_
        WinWidth=0.280164
        WinHeight=0.041458
        WinLeft=0.707875
        WinTop=0.507177
        Hint="Select a weapon to auto-apply Artificer Charm Alpha on when spawning."
        OnChange=RPGMenu_ArtificersWorkbenchWindow.AutoApplySelected
    End Object
    cmbAutoApplyAlpha=cmbAutoApplyAlpha_

    Begin Object class=GUIComboBox Name=cmbAutoApplyBeta_
        WinWidth=0.280164
        WinHeight=0.041458
        WinLeft=0.707875
        WinTop=0.686195
        Hint="Select a weapon to auto-apply Artificer Charm Beta on when spawning."
        OnChange=RPGMenu_ArtificersWorkbenchWindow.AutoApplySelected
    End Object
    cmbAutoApplyBeta=cmbAutoApplyBeta_

    Begin Object class=GUIComboBox Name=cmbAutoApplyGamma_
        WinWidth=0.280164
        WinHeight=0.041458
        WinLeft=0.707875
        WinTop=0.865391
        Hint="Select a weapon to auto-apply Artificer Charm Gamma on when spawning."
        OnChange=RPGMenu_ArtificersWorkbenchWindow.AutoApplySelected
    End Object
    cmbAutoApplyGamma=cmbAutoApplyGamma_

    Begin Object Class=GUILabel Name=lblAutoApplyAlpha_
        WinWidth=0.280164
        WinHeight=0.039407
        WinLeft=0.707875
        WinTop=0.468261
        StyleName="NoBackground"
    End Object
    lblAutoApplyAlpha=GUILabel'lblAutoApplyAlpha_'

    Begin Object Class=GUILabel Name=lblAutoApplyBeta_
        WinWidth=0.280164
        WinHeight=0.039407
        WinLeft=0.707875
        WinTop=0.647278
        StyleName="NoBackground"
    End Object
    lblAutoApplyBeta=GUILabel'lblAutoApplyBeta_'

    Begin Object Class=GUILabel Name=lblAutoApplyGamma_
        WinWidth=0.280164
        WinHeight=0.039407
        WinLeft=0.707875
        WinTop=0.826116
        StyleName="NoBackground"
    End Object
    lblAutoApplyGamma=GUILabel'lblAutoApplyGamma_'

    Begin Object Class=GUIScrollTextBox Name=lbDesc_
        WinWidth=0.270051
        WinHeight=0.152044
        WinLeft=0.712384
        WinTop=0.214958
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
        WinWidth=0.054630
        WinHeight=0.100579
        WinLeft=0.712382
        WinTop=0.078083
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
        OnClick=RPGMenu_ArtificersWorkbenchWindow.ShowHelp
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

    WindowTitle="Artificer's Workbench"

    Text_HintHelp="Show the help message."

    Text_NoAutoApply="Do not auto-apply"

    Text_AutoApplyAlpha="Auto-apply Charm Alpha on:"
    Text_AutoApplyBeta="Auto-apply Charm Beta on:"
    Text_AutoApplyGamma="Auto-apply Charm Gamma on:"
}
