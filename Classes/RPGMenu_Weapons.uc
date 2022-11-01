//=============================================================================
// RPGMenu_Weapons.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMenu_Weapons extends RPGMenu_TabPage
    DependsOn(RPGCharSettings);

var automated GUISectionBackground sbSpinnyWeap;
var automated GUISectionBackground sbWeapons;
var automated GUISectionBackground sbModifiers;
var automated GUISectionBackground sbWeaponDesc;
var automated GUISectionBackground sbSettings;

var automated GUIListBox lbWeapons;
var automated GUIListBox lbModifiers;
var automated GUIScrollTextBox lbDesc;

var automated moNumericEdit neModifierLevel;
var automated moCheckBox chShowFavorites;
var automated GUIButton btFavorite;

var automated GUIImage imHeart;

var array<string> WeaponClassNames;
var array<class<Weapon> > WeaponClasses;

var bool bInitialized;

var class<Weapon> SelectedWeapon;
var class<RPGWeaponModifier> SelectedModifier;
var int SelectedModifierLevel;
var bool bIsFavorite;

var bool bIgnoreNextChange;

var() RPGSpinnyWeap SpinnyWeap;
var() vector SpinnyWeapOffset;
var string ModifierDescription;
var FX_WeaponMenuHearts HeartsEffect;

var localized string Text_ModifierLevel;
var localized string Text_ShowFavorites;
var localized string Text_Favorite, Text_Unfavorite;
var localized string Text_NotNormallyAllowed;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    lbWeapons.List.bDropSource = false;
    lbWeapons.List.bDropTarget = false;
    lbWeapons.List.bMultiSelect = false;
    lbWeapons.List.bSorted = true;
    lbWeapons.OnClick = SelectWeapon;
    lbWeapons.OnKeyEvent = WeaponListKeyEvent;

    lbModifiers.List.bDropSource = false;
    lbModifiers.List.bDropTarget = false;
    lbModifiers.List.bMultiSelect = false;
    lbModifiers.List.bSorted = true;
    lbModifiers.OnClick = SelectModifier;
    lbModifiers.OnKeyEvent = ModifierListKeyEvent;

    lbWeapons.List.OnDrawItem = InternalDrawWeaponListItem;
    lbModifiers.List.OnDrawItem = InternalDrawModifierListItem;

    neModifierLevel.Caption = Text_ModifierLevel;
    neModifierLevel.InitComponent(MyController, Self);

    chShowFavorites.Caption = Text_ShowFavorites;
    chShowFavorites.InitComponent(MyController, Self);
}

function InitMenu()
{
    PopulateLists();

    SpinnyWeap = PlayerOwner().Spawn(class'RPGSpinnyWeap',,,, PlayerOwner().Rotation);
    SpinnyWeap.bHidden = true;

    lbWeapons.List.SilentSetIndex(0);
    lbModifiers.List.SilentSetIndex(0);
    SelectWeapon(None);
    SelectModifier(None);

    bInitialized = true;
    CheckFavorite();
}

function InternalDrawWeaponListItem(Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local GUIStyles DStyle;
    local float XL, YL;

    if(bSelected)
        DStyle = lbWeapons.List.SelectedStyle;
    else
        DStyle = lbWeapons.List.Style;
    DStyle.Draw(C, lbWeapons.List.MenuState, X, Y, W, H);

    DStyle.DrawText(C, lbWeapons.List.MenuState, X, Y, W, H, TXTA_Center, lbWeapons.List.GetItemAtIndex(Item), lbWeapons.List.FontScale);

    //draw heart icon next to favorited weapons
    if(RPGMenu.RPRI.IsFavorite(class<Weapon>(lbWeapons.List.GetObjectAtIndex(Item)), None, true))
    {
        DStyle.TextSize(C, lbWeapons.List.MenuState, lbWeapons.List.GetItemAtIndex(Item), XL, YL, lbWeapons.List.FontScale);
        C.SetPos(X + (W * 0.5) - (XL * 0.5) - H * 1.5, Y);
        C.Style = 5; //STY_Alpha
        C.DrawColor = C.MakeColor(232, 160, 255);
        C.DrawTile(Texture'HeartIcon', H, H, 0, 0, Texture'HeartIcon'.MaterialUSize(), Texture'HeartIcon'.MaterialVSize());
    }
}

function InternalDrawModifierListItem(Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local GUIStyles DStyle;
    local float XL, YL;

    if(bSelected)
        DStyle = lbModifiers.List.SelectedStyle;
    else
        DStyle = lbModifiers.List.Style;
    DStyle.Draw(C, lbModifiers.List.MenuState, X, Y, W, H);

    DStyle.DrawText(C, lbModifiers.List.MenuState, X, Y, W, H, TXTA_Center, lbModifiers.List.GetItemAtIndex(Item), lbModifiers.List.FontScale);

    //draw heart icon next to favorited modifiers
    if(RPGMenu.RPRI.IsFavorite(class<Weapon>(lbWeapons.List.GetObject()), class<RPGWeaponModifier>(lbModifiers.List.GetObjectAtIndex(Item))))
    {
        DStyle.TextSize(C, lbModifiers.List.MenuState, lbModifiers.List.GetItemAtIndex(Item), XL, YL, lbModifiers.List.FontScale);
        C.SetPos(X + (W * 0.5) - (XL * 0.5) - H * 1.5, Y);
        C.Style = 5; //STY_Alpha
        C.DrawColor = C.MakeColor(232, 160, 255);
        C.DrawTile(Texture'HeartIcon', H, H, 0, 0, Texture'HeartIcon'.MaterialUSize(), Texture'HeartIcon'.MaterialVSize());
    }
}

function InternalDraw(Canvas C)
{
    local vector CamPos;
    local rotator CamRot;
    local vector X, Y, Z;

    //draw spinny wep and/or hearts effect
    if(SpinnyWeap != None || HeartsEffect != None)
    {
        C.GetCameraLocation(CamPos, CamRot);
        GetAxes(CamRot, X, Y, Z);
    }
    else
        return;

    if(SpinnyWeap != None && SpinnyWeap.DrawType != DT_None)
    {
        SpinnyWeap.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z));

        C.DrawActorClipped(SpinnyWeap, false, sbSpinnyWeap.ClientBounds[0], sbSpinnyWeap.ClientBounds[1], sbSpinnyWeap.ClientBounds[2] - sbSpinnyWeap.ClientBounds[0], sbSpinnyWeap.ClientBounds[3] - sbSpinnyWeap.ClientBounds[1], true, 90.0);
    }
    if(HeartsEffect != None)
    {
        HeartsEffect.SetLocation(CamPos);
        HeartsEffect.SetRotation(CamRot);
        C.DrawActorClipped(HeartsEffect, false, 0, 0, C.ClipX, C.ClipY, true, 90.0f);
    }
}

function bool WeaponListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectWeapon(lbWeapons.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool ModifierListKeyEvent(out byte Key, out byte State, float delta)
{
    if((Key == 38 || Key == 40) && State == 3) //up / down key released
    {
        SelectModifier(lbModifiers.List);
        return true;
    }
    else
    {
        return false;
    }
}

function bool SelectWeapon(GUIComponent Sender)
{
    local class<Weapon> NewWeapon;
    local class<Pickup> PickupClass;
    local class<InventoryAttachment> AttachClass;
    local int i;

    RPGMenu.RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    NewWeapon = class<Weapon>(lbWeapons.List.GetObject());
    if(NewWeapon != SelectedWeapon)
        SelectedWeapon = NewWeapon;
    else
        return true;

    //if showing only favorites, rebuild the modifier list when we select a favorited weapon
    if(chShowFavorites.IsChecked())
    {
        lbModifiers.List.bNotify = false;
        lbModifiers.List.Clear();
        for(i = 0; i < RPGMenu.RPRI.RRI.MAX_WEAPONMODIFIERS; i++)
        {
            if(RPGMenu.RPRI.RRI.WeaponModifiers[i] != None && RPGMenu.RPRI.IsFavorite(SelectedWeapon, RPGMenu.RPRI.RRI.WeaponModifiers[i]))
                lbModifiers.List.Add(FormatModifierName(RPGMenu.RPRI.RRI.WeaponModifiers[i]), RPGMenu.RPRI.RRI.WeaponModifiers[i], string(i));
        }
        lbModifiers.List.bNotify = true;

        //select the modifier again in case we need to change it
        SelectModifier(None);
    }

    if(SpinnyWeap != None)
    {
        if(SelectedWeapon != None)
        {
            PickupClass = SelectedWeapon.default.PickupClass;
            AttachClass = SelectedWeapon.default.AttachmentClass;

            if(PickupClass != None && PickupClass.default.StaticMesh != None)
            {
                SpinnyWeap.LinkMesh(None);
                SpinnyWeap.SetStaticMesh(PickupClass.default.StaticMesh);
                SpinnyWeap.SetDrawScale(PickupClass.default.DrawScale);
                SpinnyWeap.SetDrawScale3D(PickupClass.default.DrawScale3D);

                SpinnyWeap.OriginalSkins = PickupClass.default.Skins;

                SpinnyWeap.SetDrawType(DT_StaticMesh);
            }
            else if(AttachClass != None && AttachClass.default.Mesh != None)
            {
                SpinnyWeap.SetStaticMesh(None);
                SpinnyWeap.LinkMesh(AttachClass.default.Mesh);
                SpinnyWeap.SetDrawScale(1.5 * AttachClass.default.DrawScale);

                SpinnyWeap.OriginalSkins = PickupClass.default.Skins;

                SpinnyWeap.SetDrawScale3D(AttachClass.default.DrawScale3D * 1.5 * vect(0, 0, -1));

                SpinnyWeap.SetDrawType(DT_Mesh);
            }

            if(SelectedModifier != None)
            {
                //re-apply modifier overlay
                if(SelectedModifier.default.ModifierOverlay != None)
                    SpinnyWeap.SetOverlayMaterial(SelectedModifier.default.ModifierOverlay, 9999, true);
            }
            else
            {
                //no modifier selected, so get rid of the overlay
                if(SpinnyWeap.OverlayMaterial != None)
                    SpinnyWeap.SetOverlayMaterial(None, 0, true);
            }
        }
        else
        {
            SpinnyWeap.SetDrawType(DT_None);
        }

        //update description text
        lbDesc.MyScrollText.bNoTeletype = false;
        lbDesc.SetContent(GetDescriptionText());
    }

    if(bInitialized)
        CheckFavorite();

    return true;
}

function bool SelectModifier(GUIComponent Sender)
{
    local class<RPGWeaponModifier> NewModifier;

    NewModifier = class<RPGWeaponModifier>(lbModifiers.List.GetObject());

    if(NewModifier != None && NewModifier != SelectedModifier)
    {
        SelectedModifier = NewModifier;

        if(SelectedModifier.default.ModifierOverlay != None)
            SpinnyWeap.SetOverlayMaterial(SelectedModifier.default.ModifierOverlay, 9999, true);

        neModifierLevel.Setup(SelectedModifier.default.MinModifier, SelectedModifier.default.MaxModifier, 1);

        if(neModifierLevel.MenuState == MSAT_Disabled)
            neModifierLevel.EnableMe();
    }
    else if(NewModifier == None)
    {
        SelectedModifier = None;
        if(SpinnyWeap.OverlayMaterial != None)
            SpinnyWeap.SetOverlayMaterial(None, 0, true);
        neModifierLevel.Setup(0, 0, 1);

        if(neModifierLevel.MenuState != MSAT_Disabled)
            neModifierLevel.DisableMe();
    }

    //update modifier level
    bIgnoreNextChange = true;
    neModifierLevel.SetValue(Clamp(SelectedModifierLevel, SelectedModifier.default.MinModifier, SelectedModifier.default.MaxModifier));
    bIgnoreNextChange = false;

    //hack to force modifier update if zero and zero is not allowed for this modifier
    InternalOnChange(neModifierLevel);

    //update description text, with teletype
    lbDesc.MyScrollText.bNoTeletype = false;
    lbDesc.SetContent(GetDescriptionText());

    if(bInitialized)
        CheckFavorite();

    return true;
}

function CheckFavorite()
{
    //for some reason the heart image would always be visible when opening the menu even if SetVisibility was used here
    //no idea what's going on with that...
    bIsFavorite = RPGMenu.RPRI.IsFavorite(SelectedWeapon, SelectedModifier);
    if(bIsFavorite)
    {
        btFavorite.Caption = Text_Unfavorite;
        imHeart.Image = Texture'HeartIcon';
    }
    else
    {
        btFavorite.Caption = Text_Favorite;
        imHeart.Image = None;
    }
}

function string GetDescriptionText()
{
    local string Description;

    if(SelectedWeapon == None || SelectedModifier == None)
        return "";

    Description = SelectedModifier.static.ConstructItemName(SelectedWeapon, SelectedModifierLevel) $ "|";
    Description $= "================||" $ SelectedModifier.static.StaticGetDescription(SelectedModifierLevel);

    if(!SelectedModifier.static.AllowedFor(SelectedWeapon))
        Description $= "||*" @ Text_NotNormallyAllowed;

    return Description;
}

function PopulateLists()
{
    local int i;

    lbWeapons.List.bNotify = false;
    lbWeapons.List.Clear();
    WeaponClasses.Length = WeaponClassNames.Length;
    for(i = 0; i < WeaponClassNames.Length; i++)
    {
        WeaponClasses[i] = class<Weapon>(DynamicLoadObject(WeaponClassNames[i], class'Class'));

        if(WeaponClasses[i] != None)
        {
            if(!chShowFavorites.IsChecked() || RPGMenu.RPRI.IsFavorite(WeaponClasses[i], None, true))
                lbWeapons.List.Add(WeaponClasses[i].default.ItemName, WeaponClasses[i], string(i));
        }
    }
    lbWeapons.List.bNotify = true;

    lbModifiers.List.bNotify = false;
    lbModifiers.List.Clear();
    for(i = 0; i < RPGMenu.RPRI.RRI.MAX_WEAPONMODIFIERS; i++)
    {
        if(RPGMenu.RPRI.RRI.WeaponModifiers[i] != None)
        {
            if(!chShowFavorites.IsChecked() || RPGMenu.RPRI.IsFavorite(SelectedWeapon, RPGMenu.RPRI.RRI.WeaponModifiers[i]))
                lbModifiers.List.Add(FormatModifierName(RPGMenu.RPRI.RRI.WeaponModifiers[i]), RPGMenu.RPRI.RRI.WeaponModifiers[i], string(i));
        }
    }
    lbModifiers.List.bNotify = true;
}

function InternalOnChange(GUIComponent Sender)
{
    local class<Weapon> OldSelectedWeapon;
    local class<RPGWeaponModifier> OldSelectedModifier;
    local int i;

    if(bIgnoreNextChange)
        return;

    switch(Sender)
    {
        case neModifierLevel:
            if(neModifierLevel.GetValue() == 0 && !SelectedModifier.default.bCanHaveZeroModifier)
            {
                bIgnoreNextChange = true;
                if(SelectedModifierLevel > 0)
                {
                    if(SelectedModifier.default.MinModifier < 0)
                        neModifierLevel.SetValue(-1);
                    else
                        neModifierLevel.SetValue(1);
                }
                else
                {
                    if(SelectedModifier.default.MaxModifier > 0)
                        neModifierLevel.SetValue(1);
                    else
                        neModifierLevel.SetValue(-1);
                }
                bIgnoreNextChange = false;
            }
            SelectedModifierLevel = neModifierLevel.GetValue();
            lbDesc.MyScrollText.bNoTeletype = true;
            lbDesc.SetContent(GetDescriptionText());
            break;
        case chShowFavorites:
            //try and reselect old choices if theyre available
            OldSelectedWeapon = class<Weapon>(lbWeapons.List.GetObject());
            OldSelectedModifier = class<RPGWeaponModifier>(lbModifiers.List.GetObject());

            PopulateLists();

            for(i = 0; i < lbWeapons.List.Elements.Length; i++)
            {
                if(lbWeapons.List.GetObjectAtIndex(i) == OldSelectedWeapon)
                {
                    lbWeapons.List.SilentSetIndex(i);
                    break;
                }
            }
            for(i = 0; i < lbModifiers.List.Elements.Length; i++)
            {
                if(lbModifiers.List.GetObjectAtIndex(i) == OldSelectedModifier)
                {
                    lbModifiers.List.SilentSetIndex(i);
                    break;
                }
            }

            SelectWeapon(None);
            SelectModifier(None);

            lbDesc.MyScrollText.bNoTeletype = true;
            lbDesc.SetContent(GetDescriptionText());

            break;
    }
}

function bool InternalOnClick(GUIComponent Sender)
{
    switch(Sender)
    {
        case btFavorite:
            if(bIsFavorite)
            {
                RPGMenu.RPRI.RemoveFavorite(SelectedWeapon, SelectedModifier);
                bIsFavorite = false;
                btFavorite.Caption = Text_Favorite;
                imHeart.Image = None;
            }
            else
            {
                RPGMenu.RPRI.AddFavorite(SelectedWeapon, SelectedModifier);
                bIsFavorite = true;
                btFavorite.Caption = Text_Unfavorite;
                imHeart.Image = Texture'HeartIcon';

                if(FRand() <= 0.01)
                {
                    PlayerOwner().ClientPlaySound(sound'Wow',, 1);
                    HeartsEffect = PlayerOwner().Spawn(class'FX_WeaponMenuHearts',PlayerOwner(),,, PlayerOwner().Rotation);
                    HeartsEffect.Menu = Self;
                }
            }
            break;
    }

    return true;
}

static final function string FormatModifierName(class<RPGWeaponModifier> ModifierClass)
{
    local string sp, sn;

    if(ModifierClass.default.MaxModifier >= 0)
        sp = class'Util'.static.Trim(Repl(Repl(ModifierClass.default.PatternPos, "$W", ""), "of", ""));
    if(ModifierClass.default.MinModifier < 0)
        sn = class'Util'.static.Trim(Repl(Repl(ModifierClass.default.PatternNeg, "$W", ""), "of", ""));

    if(sp != "" && sn != "")
        return sp $ "/" $ sn;
    else if(sp != "")
        return sp;
    else
        return sn;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    if(SpinnyWeap != None)
    {
        SpinnyWeap.Destroy();
        SpinnyWeap = None;
    }
    HeartsEffect = None;

    //force re-displaying spinnyweap
    SelectedWeapon = None;
    SelectedModifier = None;
}

defaultproperties
{
    WeaponClassNames(0)="XWeapons.ShieldGun"
    WeaponClassNames(1)="XWeapons.AssaultRifle"
    WeaponClassNames(2)="XWeapons.BioRifle"
    WeaponClassNames(3)="XWeapons.ShockRifle"
    WeaponClassNames(4)="XWeapons.LinkGun"
    WeaponClassNames(5)="XWeapons.Minigun"
    WeaponClassNames(6)="XWeapons.FlakCannon"
    WeaponClassNames(7)="XWeapons.RocketLauncher"
    WeaponClassNames(8)="XWeapons.SniperRifle"
    WeaponClassNames(9)="XWeapons.Painter"
    WeaponClassNames(10)="XWeapons.Redeemer"
    WeaponClassNames(11)="Onslaught.ONSMineLayer"
    WeaponClassNames(12)="Onslaught.ONSGrenadeLauncher"
    WeaponClassNames(13)="Onslaught.ONSAVRiL"
    WeaponClassNames(14)="OnslaughtFull.ONSPainter"
    WeaponClassNames(15)="UTClassic.ClassicSniperRifle"
    Text_ModifierLevel="Preview Modifier Level"
    Text_ShowFavorites="Favorites Only"
    Text_Favorite="Favorite"
    Text_Unfavorite="Unfavorite"
    Text_NotNormallyAllowed="This weapon/modifier combination is not naturally occuring!"

    Begin Object Class=AltSectionBackground Name=sbSpinnyWeap_
        Caption="Weapon Preview"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.412921
        WinHeight=0.461826
        WinLeft=0.000000
        WinTop=0.013226
        OnPreDraw=sbSpinnyWeap_.InternalPreDraw
    End Object
    sbSpinnyWeap=GUISectionBackground'sbSpinnyWeap_'

    Begin Object Class=AltSectionBackground Name=sbWeapons_
        Caption="Weapons"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.348149
        WinHeight=0.461826
        WinLeft=0.000000
        WinTop=0.480340
        OnPreDraw=sbWeapons_.InternalPreDraw
    End Object
    sbWeapons=GUISectionBackground'sbWeapons_'

    Begin Object Class=AltSectionBackground Name=sbModifiers_
        Caption="Magic Weapon Modifiers"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.399219
        WinHeight=0.461826
        WinLeft=0.351245
        WinTop=0.480340
        OnPreDraw=sbModifiers_.InternalPreDraw
    End Object
    sbModifiers=GUISectionBackground'sbModifiers_'

    Begin Object Class=AltSectionBackground Name=sbWeaponDesc_
        Caption="Weapon Description Preview"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.578588
        WinHeight=0.461826
        WinLeft=0.416017
        WinTop=0.013226
        OnPreDraw=sbWeaponDesc_.InternalPreDraw
    End Object
    sbWeaponDesc=GUISectionBackground'sbWeaponDesc_'

    Begin Object Class=AltSectionBackground Name=sbSettings_
        Caption="Settings"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.241026
        WinHeight=0.461826
        WinLeft=0.753579
        WinTop=0.480340
        OnPreDraw=sbSettings_.InternalPreDraw
    End Object
    sbSettings=GUISectionBackground'sbSettings_'

    Begin Object Class=GUIListBox Name=lbWeapons_
        WinWidth=0.314564
        WinHeight=0.344005
        WinLeft=0.017578
        WinTop=0.538696
        bVisibleWhenEmpty=true
        Hint="Select a weapon."
        StyleName="NoBackground"
    End Object
    lbWeapons=lbWeapons_

    Begin Object Class=GUIListBox Name=lbModifiers_
        WinWidth=0.365634
        WinHeight=0.344005
        WinLeft=0.368703
        WinTop=0.538696
        bVisibleWhenEmpty=true
        Hint="Select a weapon modifier."
        StyleName="NoBackground"
    End Object
    lbModifiers=lbModifiers_

    Begin Object Class=GUIScrollTextBox Name=lbDesc_
        WinWidth=0.540289
        WinHeight=0.284988
        WinLeft=0.436924
        WinTop=0.071940
        CharDelay=0.001250
        EOLDelay=0.001250
        bNeverFocus=true
        bAcceptsInput=false
        bVisibleWhenEmpty=True
        FontScale=FNS_Small
        StyleName="NoBackground"
    End Object
    lbDesc=lbDesc_

    Begin Object Class=moNumericEdit Name=neModifierLevel_
        WinWidth=0.391999
        WinHeight=0.045850
        WinLeft=0.582511
        WinTop=0.365825
        ComponentWidth=0.25000000
        CaptionWidth=0.6000000
        ComponentJustification=TXTA_Right
        LabelJustification=TXTA_Left
        bAutoSizeCaption=True
        bHeightFromComponent=False
        bBoundToParent=True
        bScaleToParent=True
        OnChange=RPGMenu_Weapons.InternalOnChange
    End Object
    neModifierLevel=neModifierLevel_

    Begin Object Class=moCheckBox Name=chShowFavorites_
        WinWidth=0.208893
        WinHeight=0.045850
        WinLeft=0.770599
        WinTop=0.554540
        ComponentWidth=0.25000000
        CaptionWidth=0.6000000
        ComponentJustification=TXTA_Right
        LabelJustification=TXTA_Left
        bAutoSizeCaption=True
        bHeightFromComponent=False
        bBoundToParent=True
        bScaleToParent=True
        OnChange=RPGMenu_Weapons.InternalOnChange
    End Object
    chShowFavorites=chShowFavorites_

    Begin Object Class=GUIButton Name=btFavorite_
        WinWidth=0.162805
        WinHeight=0.072008
        WinLeft=0.791775
        WinTop=0.789970
        bBoundToParent=True
        bScaleToParent=True
        OnClick=RPGMenu_Weapons.InternalOnClick
    End Object
    btFavorite=btFavorite_

    Begin Object Class=GUIImage Name=imHeart_
        ImageStyle=ISTY_Justified
        ImageColor=(R=232,G=160,B=232)
        WinWidth=0.086822
        WinHeight=0.125436
        WinLeft=0.021983
        WinTop=0.076215
        bBoundToParent=True
        bScaleToParent=True
    End Object
    imHeart=imHeart_

    OnRendered=InternalDraw
    SpinnyWeapOffset=(X=80)
}
