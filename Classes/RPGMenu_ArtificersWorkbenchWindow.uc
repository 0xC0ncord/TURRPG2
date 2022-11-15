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
var bool bDirtyCharmA, bDirtyCharmB, bDirtyCharmC, bDirtyAutoApply;
var bool bIgnoreNextChange;

var automated GUISectionBackground sbModifierPool, sbListCharmA, sbListCharmB,
                                   sbListCharmC, sbSettings, sbDescription,
                                   sbMessages;
var automated GUIListBox lbAugmentPool;
var automated GUITreeListBox lbCharmA, lbCharmB, lbCharmC;
var automated GUIGFXButton btAddCharmA, btRemoveCharmA;
var automated GUIGFXButton btAddCharmB, btRemoveCharmB;
var automated GUIGFXButton btAddCharmC, btRemoveCharmC;
var automated GUIComboBox cmbAutoApplyAlpha, cmbAutoApplyBeta, cmbAutoApplyGamma;
var automated GUILabel lblAutoApplyAlpha, lblAutoApplyBeta, lblAutoApplyGamma;
var automated GUIImage imIcon;
var automated GUIScrollTextBox lbDesc, lbMessages;
var automated GUIButton btHelp;

var class<Weapon> OldAutoApplyWeaponAlpha, OldAutoApplyWeaponBeta, OldAutoApplyWeaponGamma;
var array<GUIListElem> AutoApplyAlphaList, AutoApplyBetaList, AutoApplyGammaList;

var GUITreeList LastInteractedList; //list which we were last interacting with
                                //which isn't the modifier pool

var localized string WindowTitle;

var localized string Text_HintHelp;

var localized string Text_NoAutoApply;

var localized string Text_AutoApplyAlpha;
var localized string Text_AutoApplyBeta;
var localized string Text_AutoApplyGamma;

var localized string Text_CannotAdd;

var RPGSpinnyWeap SpinnyCharmA, SpinnyCharmB, SpinnyCharmC;
var vector SpinnyCharmOffset;

//For tree list compacting
struct CharmTreeNodeStruct
{
    var string Caption;
    var string Value;
    var string ParentCaption;
    var int Count;
};

struct ParentNodeStruct
{
    var string ChildCaption;
    var bool bExpanded;
};

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    lbAugmentPool.List.bInitializeList = false;
    lbAugmentPool.List.bDropSource = true;
    lbAugmentPool.List.bDropTarget = true;
    lbAugmentPool.List.bMultiSelect = true;
    lbAugmentPool.List.bSorted = true;
    lbAugmentPool.MyScrollbar.WinWidth = 0.015;

    lbCharmA.List.bInitializeList = false;
    lbCharmA.List.bDropSource = true;
    lbCharmA.List.bDropTarget = true;
    lbCharmA.List.bMultiSelect = true;
    lbCharmA.List.bSorted = true;
    lbCharmA.List.bAllowParentSelection = true;
    lbCharmA.MyScrollbar.WinWidth = 0.015;

    lbCharmB.List.bInitializeList = false;
    lbCharmB.List.bDropSource = true;
    lbCharmB.List.bDropTarget = true;
    lbCharmB.List.bMultiSelect = true;
    lbCharmB.List.bSorted = true;
    lbCharmB.List.bAllowParentSelection = true;
    lbCharmB.MyScrollbar.WinWidth = 0.015;

    lbCharmC.List.bInitializeList = false;
    lbCharmC.List.bDropSource = true;
    lbCharmC.List.bDropTarget = true;
    lbCharmC.List.bMultiSelect = true;
    lbCharmC.List.bSorted = true;
    lbCharmC.List.bAllowParentSelection = true;
    lbCharmC.MyScrollbar.WinWidth = 0.015;

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

    lbDesc.MyScrollbar.WinWidth = 0.015;
    lbMessages.MyScrollbar.WinWidth = 0.015;

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

    SpinnyCharmA = PlayerOwner().Spawn(class'RPGSpinnyWeap',,,, PlayerOwner().Rotation);
    SpinnyCharmA.bHidden = true;
    SpinnyCharmA.SetStaticMesh(StaticMesh'MonsterSummon');
    SpinnyCharmA.Skins[0] = Shader'WOPAlphaShader';

    SpinnyCharmB = PlayerOwner().Spawn(class'RPGSpinnyWeap',,,, PlayerOwner().Rotation);
    SpinnyCharmB.bHidden = true;
    SpinnyCharmB.SetStaticMesh(StaticMesh'MonsterSummon');
    SpinnyCharmB.Skins[0] = Shader'WOPBetaShader';

    SpinnyCharmC = PlayerOwner().Spawn(class'RPGSpinnyWeap',,,, PlayerOwner().Rotation);
    SpinnyCharmC.bHidden = true;
    SpinnyCharmC.SetStaticMesh(StaticMesh'MonsterSummon');
    SpinnyCharmC.Skins[0] = Shader'WOPGammaShader';

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

function SelectModifier(optional GUIVertList List)
{
    local class<ArtificerAugmentBase> MClass;

    RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    switch(List)
    {
        case None:
            List = lbAugmentPool.List;
        case lbAugmentPool.List:
            MClass = class<ArtificerAugmentBase>(GUIList(List).GetObject());
            break;
        case lbCharmA.List:
        case lbCharmB.List:
        case lbCharmC.List:
            if(GUITreeList(List).HasChildren(List.Index))
                MClass = class<ArtificerAugmentBase>(DynamicLoadObject(GUITreeList(List).GetValueAtIndex(List.Index + 1), class'Class'));
            else
                MClass = class<ArtificerAugmentBase>(DynamicLoadObject(GUITreeList(List).GetValue(), class'Class'));
            break;
    }

    if(MClass != None)
    {
        sbDescription.Caption = MClass.default.ModifierName;
        lbDesc.SetContent(MClass.static.StaticGetLongDescription());

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
    local GUITreeList Target;
    local int i;
    local array<RPGCharSettings.ArtificerAugmentStruct> Augments;
    local string Reason;
    local string Messages;

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

    UnpackCharmList(Target, Augments);

    lbAugmentPool.List.bNotify = false;
    for(i = PendingElements.Length - 1; i >= 0; i--)
    {
        if(class<ArtificerAugmentBase>(PendingElements[i].ExtraData).static.InsertInto(Augments, Reason))
        {
            lbAugmentPool.List.RemoveElement(PendingElements[i],, true);
            Target.AddItem(PendingElements[i].Item, string(PendingElements[i].ExtraData));
        }
        else
        {
            if(Messages != "")
                Messages $= "||";
            Messages $= Repl(Text_CannotAdd, "$1", class<ArtificerAugmentBase>(PendingElements[i].ExtraData).default.ModifierName) $ "|" $ Reason;
        }
    }

    lbAugmentPool.List.bNotify = true;
    lbAugmentPool.List.ClearPendingElements();
    lbAugmentPool.List.SetIndex(lbAugmentPool.List.Index); //to check if button states should change

    lbAugmentPool.List.Sort();

    CompactCharmList(Target);
    Target.Sort();

    lbMessages.SetContent(Messages);

    switch(Target)
    {
        case lbCharmA.List:
            bDirtyCharmA = true;
            break;
        case lbCharmB.List:
            bDirtyCharmB = true;
            break;
        case lbCharmC.List:
            bDirtyCharmC = true;
            break;
    }

    return true;
}

function bool RemoveModifier(GUIComponent Sender)
{
    local array<GUITreeNode> PendingNodes;
    local int Length;
    local array<int> ChildIndices;
    local int i, x, y;
    local GUITreeList List;

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

    PendingNodes = List.GetPendingElements(true);
    Length = PendingNodes.Length;

    //strip out duplicates and add unselected children
    for(i = 0; i < Length; i++)
    {
        if(PendingNodes[i].Value == "" && List.HasChildren(i))
        {
            ChildIndices = List.GetChildIndexList(List.FindIndex(PendingNodes[i].Caption));

            //remove duplicates
            for(x = 0; x < List.SelectedItems.Length; x++)
            {
                for(y = 0; y < ChildIndices.Length; y++)
                {
                    if(List.SelectedItems[x] == ChildIndices[y])
                    {
                        ChildIndices.Remove(y, 1);
                        break;
                    }
                }
            }

            //add children
            for(x = 0; x < ChildIndices.Length; x++)
                PendingNodes[PendingNodes.Length] = List.Elements[ChildIndices[x]];

            PendingNodes.Remove(i, 1); //remove the parent itself
        }
    }

    List.bNotify = false;
    for(i = PendingNodes.Length - 1; i >= 0; i--)
    {
        List.RemoveElement(PendingNodes[i],, true);
        lbAugmentPool.List.Add(PendingNodes[i].Caption, class<ArtificerAugmentBase>(DynamicLoadObject(PendingNodes[i].Value, class'Class')));
    }

    List.bNotify = true;
    List.ClearPendingElements();

    CompactCharmList(List);

    lbMessages.SetContent("");

    switch(List)
    {
        case lbCharmA.List:
            bDirtyCharmA = true;
            break;
        case lbCharmB.List:
            bDirtyCharmB = true;
            break;
        case lbCharmC.List:
            bDirtyCharmC = true;
            break;
    }

    return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
    switch(Sender)
    {
        case lbCharmA:
        case lbCharmB:
        case lbCharmC:
            SelectModifier(GUITreeListBox(Sender).List);
            LastInteractedList = GUITreeListBox(Sender).List;
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
    local GUIVertList Source;
    local array<GUIListElem> PendingElements;
    local array<GUITreeNode> PendingNodes;
    local array<int> ChildIndices;
    local int Length;
    local int i, x, y;
    local bool bTargetIsCharmList;
    local bool bSourceIsCharmList;
    local array<RPGCharSettings.ArtificerAugmentStruct> Augments;
    local string Reason;
    local string Messages;
    local class<ArtificerAugmentBase> AugmentClass;

    if(Controller == None)
        return false;

    Source = GUIVertList(Controller.DropSource);
    if(Source == None || Source == Target)
        return false;

    if(!Source.IsValid())
        return false;

    bTargetIsCharmList = (Target == lbCharmA.List || Target == lbCharmB.List || Target == lbCharmC.List);

    switch(Source)
    {
        case lbAugmentPool.List:
            PendingElements = GUIList(Source).GetPendingElements(true);
            break;
        case lbCharmA.List:
        case lbCharmB.List:
        case lbCharmC.List:
            bSourceIsCharmList = true;
            PendingNodes = GUITreeList(Source).GetPendingElements(true);
            Length = PendingNodes.Length;

            //strip out duplicates and add unselected children
            for(i = 0; i < Length; i++)
            {
                if(PendingNodes[i].Value == "" && GUITreeList(Source).HasChildren(i))
                {
                    ChildIndices = GUITreeList(Source).GetChildIndexList(GUITreeList(Source).FindIndex(PendingNodes[i].Caption));

                    //remove duplicates
                    for(x = 0; x < Source.SelectedItems.Length; x++)
                    {
                        for(y = 0; y < ChildIndices.Length; y++)
                        {
                            if(Source.SelectedItems[x] == ChildIndices[y])
                            {
                                ChildIndices.Remove(y, 1);
                                break;
                            }
                        }
                    }

                    //add children
                    for(x = 0; x < ChildIndices.Length; x++)
                        PendingNodes[PendingNodes.Length] = GUITreeList(Source).Elements[ChildIndices[x]];

                    PendingNodes.Remove(i, 1); //remove the parent itself
                }
            }
            break;
    }

    Source.bNotify = false;

    if(bTargetIsCharmList)
    {
        UnpackCharmList(GUITreeList(Target), Augments);

        if(bSourceIsCharmList)
        {
            //charm list -> charm list
            for(i = PendingNodes.Length - 1; i >= 0; i--)
            {
                AugmentClass = class<ArtificerAugmentBase>(DynamicLoadObject(PendingNodes[i].Value, class'Class'));
                if(AugmentClass.static.InsertInto(Augments, Reason))
                {
                    GUITreeList(Source).RemoveElement(PendingNodes[i],, true);
                    GUITreeList(Target).AddElement(PendingNodes[i]);
                }
                else
                {
                    if(Messages != "")
                        Messages $= "||";
                    Messages $= Repl(Text_CannotAdd, "$1", AugmentClass.default.ModifierName) $ "|" $ Reason;
                }
            }
        }
        else
        {
            //augment pool -> charm list
            for(i = PendingElements.Length - 1; i >= 0; i--)
            {
                AugmentClass = class<ArtificerAugmentBase>(PendingElements[i].ExtraData);
                if(AugmentClass.static.InsertInto(Augments, Reason))
                {
                    GUIList(Source).RemoveElement(PendingElements[i],, true);
                    GUITreeList(Target).AddItem(PendingElements[i].Item, string(PendingElements[i].ExtraData));
                }
                else
                {
                    if(Messages != "")
                        Messages $= "||";
                    Messages $= Repl(Text_CannotAdd, "$1", AugmentClass.default.ModifierName) $ "|" $ Reason;
                }
            }
        }
    }
    else
    {
        //charm list -> augment pool
        for(i = PendingNodes.Length - 1; i >= 0; i--)
        {
            GUITreeList(Source).RemoveElement(PendingNodes[i],, true);
            GUIList(Target).Add(PendingNodes[i].Caption, class<ArtificerAugmentBase>(DynamicLoadObject(PendingNodes[i].Value, class'Class')));
        }
    }

    Source.bNotify = true;
    Source.ClearPendingElements();
    Source.SetIndex(Source.Index); //to check if button states should change

    if(bSourceIsCharmList)
        CompactCharmList(GUITreeList(Source));
    if(bTargetIsCharmList)
        CompactCharmList(GUITreeList(Target));

    Source.Sort();
    GUIVertList(Target).Sort();

    lbMessages.SetContent(Messages);

    if(Source == lbCharmA.List)
        bDirtyCharmA = true;
    if(Source == lbCharmB.List)
        bDirtyCharmB = true;
    if(Source == lbCharmC.List)
        bDirtyCharmC = true;
    if(Target == lbCharmA.List)
        bDirtyCharmA = true;
    if(Target == lbCharmB.List)
        bDirtyCharmB = true;
    if(Target == lbCharmC.List)
        bDirtyCharmC = true;

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

function CompactCharmList(GUITreeList List)
{
    local int i, x;
    local class<ArtificerAugmentBase> AugmentClass;
    local array<CharmTreeNodeStruct> CharmTreeState;
    local array<ParentNodeStruct> Parents;

    //identify which and how many augments are in the list
    for(i = 0; i < List.ItemCount; i++)
    {
        if(List.Elements[i].Value == "")
        {
            x = Parents.Length;
            Parents.Length = x + 1;
            Parents[x].ChildCaption = List.Elements[i + 1].Caption;
            Parents[x].bExpanded = List.IsExpanded(i);
            continue;
        }

        for(x = 0; x < CharmTreeState.Length; x++)
        {
            if(List.Elements[i].Value == CharmTreeState[x].Value)
            {
                CharmTreeState[x].Count++;
                x = -1;
                break;
            }
        }

        if(x != -1)
        {
            x = CharmTreeState.Length;
            CharmTreeState.Length = x + 1;
            CharmTreeState[x].Caption = List.Elements[i].Caption;
            CharmTreeState[x].Value = List.Elements[i].Value;
            CharmTreeState[x].Count = 1;
        }
    }

    //update the parent captions
    for(i = 0; i < CharmTreeState.Length; i++)
    {
        AugmentClass = class<ArtificerAugmentBase>(DynamicLoadObject(CharmTreeState[i].Value, class'Class'));
        if(CharmTreeState[i].Count < AugmentClass.default.MaxLevel)
            CharmTreeState[i].ParentCaption = AugmentClass.default.ModifierName @ "(Lv." @ CharmTreeState[i].Count $ ")";
        else
            CharmTreeState[i].ParentCaption = AugmentClass.default.ModifierName @ "(Lv." @ CharmTreeState[i].Count $ ") (MAX)";
    }

    //clear the list
    List.Clear();

    //re-populate the list
    for(i = 0; i < CharmTreeState.Length; i++)
        for(x = 0; x < CharmTreeState[i].Count; x++)
            List.AddItem(CharmTreeState[i].Caption, CharmTreeState[i].Value, CharmTreeState[i].ParentCaption);

    //for expansion checking, tag each parent wth extra data to identify it

    List.Sort();

    //re-expand expanded parents
    x = 0;
    for(i = 0; i < List.ItemCount; i++)
    {
        if(List.Elements[i].Value == "")
        {
            if(Parents[x].bExpanded && Parents[x].ChildCaption == List.Elements[i + 1].Caption)
                List.Expand(i);
            x++;
        }
    }
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

function DrawListItem(GUIVertList List, Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local GUIStyles DStyle;
    local float XL, YL;
    local class<ArtificerAugmentBase> AugmentClass;
    local bool bIsDrop;
    local float PrefixOffset, CaptionOffset;
    local string Prefix;

    //transcribed from UGUIVertList::Draw because setting the delegate stops
    //selection boxes from drawing...
    bIsDrop = (Item == List.DropIndex);

    if(bSelected || (bPending && !bIsDrop))
    {
        if(List.SelectedStyle != None)
        {
            if(List.SelectedStyle.Images[List.MenuState] != None)
                List.SelectedStyle.Draw(C, List.MenuState, X, Y, W, H);
            else
            {
                C.SetPos(X, Y);
                C.DrawTile(Controller.DefaultPens[0], W, H, 0, 0, 32, 32);
            }
        }
        else
        {
            if(List.MenuState == MSAT_Focused || List.MenuState == MSAT_Pressed)
            {
                if(List.SelectedImage == None)
                {
                    C.SetPos(X, Y);
                    C.DrawTile(Controller.DefaultPens[0], W, H, 0, 0, 32, 32);
                }
                else
                {
                    C.DrawColor = List.SelectedBKColor;
                    C.SetPos(X, Y);
                    C.DrawTileStretched(List.SelectedImage, W, H);
                }
            }
        }
    }

    if(bPending && List.OutlineStyle != None)
    {
        if(List.OutlineStyle.Images[List.MenuState] != None)
        {
            if(bIsDrop)
                List.OutlineStyle.Draw(C, List.MenuState, X + 1, Y + 1, W - 2, H - 2);
            else
            {
                List.OutlineStyle.Draw(C, List.MenuState, X, Y, W, H);
                if(List.DropState == DRP_Source)
                    List.OutlineStyle.Draw(
                        C,
                        List.MenuState,
                        Controller.MouseX - List.MouseOffset[0],
                        Controller.MouseY - List.MouseOffset[1] + Y - List.ClientBounds[1],
                        List.MouseOffset[2] + List.MouseOffset[0],
                        H);
            }
        }
    }

    switch(List)
    {
        case lbAugmentPool.List:
            //manual call to DrawItem itself
            if(bSelected)
                DStyle = List.SelectedStyle;
            else
                DStyle = List.Style;

            DStyle.Draw(C, List.MenuState, X, Y, W, H);

            DStyle.DrawText(C, List.MenuState, X, Y, W, H, TXTA_Center, List.GetItemAtIndex(Item), List.FontScale);

            //now our custom code... draw an icon next to the item
            AugmentClass = class<ArtificerAugmentBase>(GUIList(List).GetObjectAtIndex(Item));
            if(AugmentClass.default.IconMaterial != None)
            {
                DStyle.TextSize(C, List.MenuState, List.GetItemAtIndex(Item), XL, YL, List.FontScale);
                C.SetPos(X + (W * 0.5) - (XL * 0.5) - H * 1.5, Y);
                C.Style = 5; //STY_Alpha
                C.DrawColor = C.MakeColor(255, 255, 255);
                C.DrawTile(
                    AugmentClass.default.IconMaterial,
                    H,
                    H,
                    0,
                    0,
                    AugmentClass.default.IconMaterial.MaterialUSize(),
                    AugmentClass.default.IconMaterial.MaterialVSize());
            }
            break;
        case lbCharmA.List:
        case lbCharmB.List:
        case lbCharmC.List:
            //manual call to DrawItem itself
            if(bSelected)
            {
                DStyle = List.SelectedStyle;
                PrefixOffset = GUITreeList(List).SelectedPrefixWidth * GUITreeList(List).GetLevelAtIndex(Item);
                // CaptionOffset = GUITreeList(List).SelectedPrefixWidth * (GUITreeList(List).GetLevelAtIndex(Item) + 1);
                CaptionOffset = (H * 2) + GUITreeList(List).SelectedPrefixWidth * (GUITreeList(List).GetLevelAtIndex(Item) + 1);
            }
            else
            {
                DStyle = List.Style;
                PrefixOffset = GUITreeList(List).PrefixWidth * GUITreeList(List).GetLevelAtIndex(Item);
                // CaptionOffset = GUITreeList(List).PrefixWidth * (GUITreeList(List).GetLevelAtIndex(Item) + 1);
                CaptionOffset = (H * 2) + GUITreeList(List).PrefixWidth * (GUITreeList(List).GetLevelAtIndex(Item) + 1);
            }

            if(GUITreeList(List).HasChildren(Item))
            {
                if(GUITreeList(List).IsExpanded(Item))
                    Prefix = "-";
                else
                    Prefix = "+";
            }

            DStyle.Draw(C, List.MenuState, X, Y, W, H);

            DStyle.DrawText(
                C,
                List.MenuState,
                X + PrefixOffset,
                Y,
                W - PrefixOffset,
                H,
                TXTA_Left,
                Prefix,
                List.FontScale);
            DStyle.DrawText(C,
                List.MenuState,
                X + CaptionOffset,
                Y,
                W - CaptionOffset,
                H,
                TXTA_Left,
                GUITreeList(List).GetCaptionAtIndex(Item),
                List.FontScale);

            //now our custom code... draw an icon next to the item
            if(GUITreeList(List).GetValueAtIndex(Item) == "")
            {
                AugmentClass = class<ArtificerAugmentBase>(DynamicLoadObject(GUITreeList(List).GetValueAtIndex(Item + 1), class'Class'));
                if(bSelected)
                    C.SetPos(X + (H * 0.5) + PrefixOffset + GUITreeList(List).SelectedPrefixWidth, Y);
                else
                    C.SetPos(X + (H * 0.5) + PrefixOffset + GUITreeList(List).PrefixWidth, Y);
            }
            else
            {
                AugmentClass = class<ArtificerAugmentBase>(DynamicLoadObject(GUITreeList(List).GetValueAtIndex(Item), class'Class'));
                if(bSelected)
                    C.SetPos(X - (H * 1.5) + CaptionOffset, Y);
                else
                    C.SetPos(X - (H * 1.5) + CaptionOffset, Y);
            }
            if(AugmentClass.default.IconMaterial != None)
            {
                DStyle.TextSize(C, List.MenuState, GUITreeList(List).GetCaptionAtIndex(Item), XL, YL, List.FontScale);
                C.Style = 5; //STY_Alpha
                C.DrawColor = C.MakeColor(255, 255, 255);
                C.DrawTile(
                    AugmentClass.default.IconMaterial,
                    H,
                    H,
                    0,
                    0,
                    AugmentClass.default.IconMaterial.MaterialUSize(),
                    AugmentClass.default.IconMaterial.MaterialVSize());
            }
            break;
    }
}

function InternalDraw(Canvas C)
{
    local vector CamPos;
    local rotator CamRot;
    local vector X, Y, Z;

    //draw spinny charms
    if(SpinnyCharmA != None || SpinnyCharmB != None || SpinnyCharmC != None)
    {
        C.GetCameraLocation(CamPos, CamRot);
        GetAxes(CamRot, X, Y, Z);
    }
    else
        return;

    if(SpinnyCharmA != None)
    {
        SpinnyCharmA.SetLocation(CamPos + (SpinnyCharmOffset.X * X) + (SpinnyCharmOffset.Y * Y) + (SpinnyCharmOffset.Z * Z));
        C.DrawActorClipped(
            SpinnyCharmA,
            false,
            lbCharmA.ClientBounds[2],
            lbCharmA.ClientBounds[1],
            sbListCharmA.ClientBounds[2] - lbCharmA.ClientBounds[2],
            sbListCharmA.ClientBounds[2] - lbCharmA.ClientBounds[2],
            true,
            90.0);
    }
    if(SpinnyCharmB != None)
    {
        SpinnyCharmB.SetLocation(CamPos + (SpinnyCharmOffset.X * X) + (SpinnyCharmOffset.Y * Y) + (SpinnyCharmOffset.Z * Z));
        C.DrawActorClipped(
            SpinnyCharmB,
            false,
            lbCharmB.ClientBounds[2],
            lbCharmB.ClientBounds[1],
            sbListCharmB.ClientBounds[2] - lbCharmB.ClientBounds[2],
            sbListCharmB.ClientBounds[2] - lbCharmB.ClientBounds[2],
            true,
            90.0);
    }
    if(SpinnyCharmC != None)
    {
        SpinnyCharmC.SetLocation(CamPos + (SpinnyCharmOffset.X * X) + (SpinnyCharmOffset.Y * Y) + (SpinnyCharmOffset.Z * Z));
        C.DrawActorClipped(
            SpinnyCharmC,
            false,
            lbCharmC.ClientBounds[2],
            lbCharmC.ClientBounds[1],
            sbListCharmC.ClientBounds[2] - lbCharmC.ClientBounds[2],
            sbListCharmC.ClientBounds[2] - lbCharmC.ClientBounds[2],
            true,
            90.0);
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

final function PackCharmList(GUITreeList List, array<RPGCharSettings.ArtificerAugmentStruct> Augments)
{
    local int i, x, y;
    local class<ArtificerAugmentBase> MClass;

    for(i = 0; i < Augments.Length; i++)
    {
        MClass = Augments[i].AugmentClass;
        if(MClass == None)
            continue;

        for(x = 0; x < Augments[i].ModifierLevel; x++)
        {
            List.AddItem(MClass.default.ModifierName, string(MClass));

            y = lbAugmentPool.List.FindItemObject(MClass);
            if(y != -1)
                lbAugmentPool.List.Remove(y,, true);
        }
    }

    CompactCharmList(List);
    List.Sort();
}

final function UnpackCharmList(GUITreeList List, out array<RPGCharSettings.ArtificerAugmentStruct> Augments)
{
    local int i, x;

    for(i = 0; i < List.ItemCount; i++)
    {
        if(List.Elements[i].Value == "")
            continue; //ignore parents

        for(x = 0; x < Augments.Length; x++)
        {
            if(string(Augments[x].AugmentClass) == List.Elements[i].Value)
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
        Augments[x].AugmentClass = class<ArtificerAugmentBase>(DynamicLoadObject(List.Elements[i].Value, class'Class'));
        Augments[x].ModifierLevel = 1;
    }
}

function AutoApplySelected(GUIComponent Sender)
{
    local GUIListElem Elem;
    local int i;

    bDirtyAutoApply = true;

    switch(Sender)
    {
        case cmbAutoApplyAlpha:
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

    if(bDirtyCharmA || bDirtyCharmB || bDirtyCharmC || bDirtyAutoApply)
    {
        Settings = RPRI.Interaction.CharSettings;

        if(bDirtyCharmA)
        {
            UnpackCharmList(lbCharmA.List, Augments);
            Settings.ArtificerCharmAlphaConfig = Augments;
            RPRI.ArtificerAugmentsAlpha = Augments;
            RPRI.ResendArtificerAugments(0);
        }

        if(bDirtyCharmB)
        {
            Augments.Length = 0;
            UnpackCharmList(lbCharmB.List, Augments);
            Settings.ArtificerCharmBetaConfig = Augments;
            RPRI.ArtificerAugmentsBeta = Augments;
            RPRI.ResendArtificerAugments(1);
        }

        if(bDirtyCharmC)
        {
            Augments.Length = 0;
            UnpackCharmList(lbCharmC.List, Augments);
            Settings.ArtificerCharmGammaConfig = Augments;
            RPRI.ArtificerAugmentsGamma = Augments;
            RPRI.ResendArtificerAugments(2);
        }

        if(bDirtyAutoApply)
        {
            Settings.ArtificerAutoApplyWeaponAlpha = class<Weapon>(cmbAutoApplyAlpha.GetObject());
            Settings.ArtificerAutoApplyWeaponBeta = class<Weapon>(cmbAutoApplyBeta.GetObject());
            Settings.ArtificerAutoApplyWeaponGamma = class<Weapon>(cmbAutoApplyGamma.GetObject());
            RPRI.ArtificerAutoApplyWeaponAlpha = Settings.ArtificerAutoApplyWeaponAlpha;
            RPRI.ArtificerAutoApplyWeaponBeta = Settings.ArtificerAutoApplyWeaponBeta;
            RPRI.ArtificerAutoApplyWeaponGamma = Settings.ArtificerAutoApplyWeaponGamma;
        }

        bDirtyCharmA = false;
        bDirtyCharmB = false;
        bDirtyCharmC = false;
        bDirtyAutoApply = false;
    }

    Super.Closed(Sender, bCancelled);
}

event Free()
{
    Super.Free();
    RPRI = None;

    if(SpinnyCharmA != None)
        SpinnyCharmA.Destroy();
    if(SpinnyCharmB != None)
        SpinnyCharmB.Destroy();
    if(SpinnyCharmC != None)
        SpinnyCharmC.Destroy();

    SpinnyCharmA = None;
    SpinnyCharmB = None;
    SpinnyCharmC = None;
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
        WinHeight=0.288971
        WinLeft=0.694855
        WinTop=0.032034
        OnPreDraw=sbDescription_.InternalPreDraw
    End Object
    sbDescription=GUISectionBackground'sbDescription_'

    Begin Object Class=AltSectionBackground Name=sbMessages_
        Caption="Messages"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.305175
        WinHeight=0.297652
        WinLeft=0.694855
        WinTop=0.323186
        OnPreDraw=sbMessages_.InternalPreDraw
    End Object
    sbMessages=GUISectionBackground'sbMessages_'

    Begin Object Class=AltSectionBackground Name=sbSettings_
        Caption="Settings"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.305175
        WinHeight=0.348578
        WinLeft=0.694855
        WinTop=0.622572
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

    Begin Object Class=GUITreeListBox Name=lbCharmA_
        WinWidth=0.252442
        WinHeight=0.225865
        WinLeft=0.324836
        WinTop=0.075056
        bVisibleWhenEmpty=true
        Hint="These are the augments active on Charm Alpha."
        StyleName="NoBackground"
    End Object
    lbCharmA=lbCharmA_

    Begin Object Class=GUITreeListBox Name=lbCharmB_
        WinWidth=0.252442
        WinHeight=0.225865
        WinLeft=0.324836
        WinTop=0.388416
        bVisibleWhenEmpty=true
        Hint="These are the augments active on Charm Beta."
        StyleName="NoBackground"
    End Object
    lbCharmB=lbCharmB_

    Begin Object Class=GUITreeListBox Name=lbCharmC_
        WinWidth=0.252442
        WinHeight=0.225865
        WinLeft=0.324836
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
        WinTop=0.703685
        Hint="Select a weapon to auto-apply Artificer Charm Alpha on when spawning."
        OnChange=RPGMenu_ArtificersWorkbenchWindow.AutoApplySelected
    End Object
    cmbAutoApplyAlpha=cmbAutoApplyAlpha_

    Begin Object class=GUIComboBox Name=cmbAutoApplyBeta_
        WinWidth=0.280164
        WinHeight=0.041458
        WinLeft=0.707875
        WinTop=0.796281
        Hint="Select a weapon to auto-apply Artificer Charm Beta on when spawning."
        OnChange=RPGMenu_ArtificersWorkbenchWindow.AutoApplySelected
    End Object
    cmbAutoApplyBeta=cmbAutoApplyBeta_

    Begin Object class=GUIComboBox Name=cmbAutoApplyGamma_
        WinWidth=0.280164
        WinHeight=0.041458
        WinLeft=0.707875
        WinTop=0.889054
        Hint="Select a weapon to auto-apply Artificer Charm Gamma on when spawning."
        OnChange=RPGMenu_ArtificersWorkbenchWindow.AutoApplySelected
    End Object
    cmbAutoApplyGamma=cmbAutoApplyGamma_

    Begin Object Class=GUILabel Name=lblAutoApplyAlpha_
        WinWidth=0.280164
        WinHeight=0.039407
        WinLeft=0.707875
        WinTop=0.665796
        StyleName="NoBackground"
    End Object
    lblAutoApplyAlpha=GUILabel'lblAutoApplyAlpha_'

    Begin Object Class=GUILabel Name=lblAutoApplyBeta_
        WinWidth=0.280164
        WinHeight=0.039407
        WinLeft=0.707875
        WinTop=0.758393
        StyleName="NoBackground"
    End Object
    lblAutoApplyBeta=GUILabel'lblAutoApplyBeta_'

    Begin Object Class=GUILabel Name=lblAutoApplyGamma_
        WinWidth=0.280164
        WinHeight=0.039407
        WinLeft=0.707875
        WinTop=0.850808
        StyleName="NoBackground"
    End Object
    lblAutoApplyGamma=GUILabel'lblAutoApplyGamma_'

    Begin Object Class=GUIScrollTextBox Name=lbDesc_
        WinWidth=0.270051
        WinHeight=0.066396
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

    Begin Object Class=GUIScrollTextBox Name=lbMessages_
        WinWidth=0.270051
        WinHeight=0.223803
        WinLeft=0.712384
        WinTop=0.360020
        CharDelay=0.001250
        EOLDelay=0.001250
        bNeverFocus=true
        bAcceptsInput=false
        bVisibleWhenEmpty=True
        FontScale=FNS_Small
        StyleName="NoBackground"
    End Object
    lbMessages=lbMessages_

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

    Text_CannotAdd="The $1 augment could not be added:"

    OnRendered=InternalDraw
    SpinnyCharmOffset=(X=60)
}
