//=============================================================================
// RPGInteraction.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGInteraction extends Interaction
    dependson(RPGArtifact);

struct Vec2
{
    var float X, Y;
};

struct Rect
{
    var float X, Y, W, H;
};

var RPGPlayerReplicationInfo RPRI;

var RPGSettings Settings;
var RPGCharSettings CharSettings;

var float TimeSeconds;

var bool bMenuEnabled; //false as long as server settings were not yet received

var bool bUpdateCanvas;

var bool bDefaultBindings, bDefaultArtifactBindings; //use default keybinds because user didn't set any
var float LastLevelMessageTime;
var Color EXPBarColor, DisabledOverlay, RedColor, WhiteColor, WhiteTrans;
var Color HUDColorTeam[4];
var localized string LevelText;
var Sound VehicleLockSound, VehicleUnlockSound;
var localized string VehicleLockedMessage, VehicleUnlockedMessage;

var Material ArtifactBorderMaterial;
var Rect ArtifactBorderMaterialRect;
var float ArtifactBorderSize;
var float ArtifactHighlightIndention;
var float ArtifactIconInnerScale;

var float ArtifactRadialSize;
var bool bArtifactRadialActive;
var int SelectedRadialSlot;
var float ArtifactRadialInputTime;
var bool bRadialInputChanged;
var float RadialInputResetTime;
var float RadialTimeAccum;
var bool bRadialEntering, bRadialExiting, bRadialJustChanged;
var float CalcRadialSize;
var array<Object> ArtifactRadialItems;
var array<float> RadialSlotTouchTime;

var float MousePosX, MousePosY;
var float ResX, ResY;

var string LastWeaponExtra;

var class<RPGArtifact> LastSelectedArtifact;
var string LastSelItemName, LastSelExtra;
var float ArtifactDrawTimer;
var Color ArtifactDrawColor;
struct OptionCostArrayStruct
{
    var array<RPGArtifact.OptionCostStruct> Arr;
};

var float ExpGain, ExpGainTimer, ExpGainDurationForever;

var array<string> Hint;
var float HintTimer;
var float HintDuration;
var Color HintColor;

var localized string ArtifactTutorialText;

//Keys
var array<EInputKey> ArtifactUseKey;

//Artifact selection options
var RPGArtifact SelectionArtifact;
var int CurrentPage, NumPages;
var int StartOption;
var localized string ArtifactMoreOptionsText;
var localized string ArtifactNAText;

//Status icon
var Material StatusIconBorderMaterial;
var Rect StatusIconBorderMaterialRect;
var Vec2 StatusIconSize;
var float StatusIconInnerScale;
var Color StatusIconOverlay;

//Pre-calculated values for PostRender - updated if the canvas size or settings changed
var Vec2 CanvasSize, FontScale, ArtifactIconPos, StatusIconPos;
var Rect ExpBarRect;
var Font TextFont;
var float ArtifactIconSize;

//Labs stuff
var string SAOFontArrayNames[9];
var Font SAOFonts[9];
var int SAOFontScreenWidthMedium[9];

event Initialized()
{
    CheckBindings();
    TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));

    //Load client settings
    Settings = new(None, "TURRPG2") class'RPGSettings';

    FindRPRI();
    CharSettings = new(None, RPRI.PRI.PlayerName) class'RPGCharSettings';
}

static function Font LoadSAOFontStatic(int i)
{
    if( default.SAOFonts[i] == None )
    {
        default.SAOFonts[i] = Font(DynamicLoadObject("TURRPG2." $ default.SAOFontArrayNames[i], class'Font'));
        if( default.SAOFonts[i] == None )
            Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.SAOFontArrayNames[i]);
    }

    return default.SAOFonts[i];
}

static function Font GetMediumSAOFontFor(Canvas Canvas)
{
    local int i;

    for ( i=0; i<8; i++ )
    {
        if ( Default.SAOFontScreenWidthMedium[i] <= Canvas.ClipX )
            return LoadSAOFontStatic(i);
    }
    return LoadSAOFontStatic(8);
}

function CheckBindings()
{
    local EInputKey Key;
    local string KeyName, KeyBinding;

    bDefaultBindings = true;
    bDefaultArtifactBindings = true;

    //detect if user made custom binds for our aliases
    for(Key = IK_None; Key < IK_OEMClear; Key = EInputKey(Key + 1))
    {
        KeyName = ViewportOwner.Actor.ConsoleCommand("KEYNAME" @ Key);
        KeyBinding = ViewportOwner.Actor.ConsoleCommand("KEYBINDING" @ KeyName);

        if(class'Util'.static.KeyHasBinding(KeyBinding, "RPGStatsMenu"))
            bDefaultBindings = false;
        else if(class'Util'.static.KeyHasBinding(KeyBinding, "ActivateItem") || class'Util'.static.KeyHasBinding(KeyBinding, "InventoryActivate"))
        {
            ArtifactUseKey[ArtifactUseKey.Length] = Key;
            bDefaultArtifactBindings = false;
        }
        else if(class'Util'.static.KeyHasBinding(KeyBinding, "NextItem") || class'Util'.static.KeyHasBinding(KeyBinding, "PrevItem"))
            bDefaultArtifactBindings = false;
    }
}

exec function Labs()
{
    if(bMenuEnabled)
    {
        if(RPGMenu(GUIController(ViewportOwner.GUIController).TopPage()) != None && RPGMenu_SettingsMaster(RPGMenu(GUIController(ViewportOwner.GUIController).TopPage()).Tabs.ActiveTab.MyPanel) != None)
        {
            ViewportOwner.GUIController.OpenMenu("TURRPG2.RPGLabsMenu");
            RPGLabsMenu(GUIController(ViewportOwner.GUIController).TopPage()).InitFor(RPRI);
        }
    }
}

exec function RPGStatsMenu()
{
    if(bMenuEnabled)
    {
        if(RPRI == None)
            FindRPRI();

        if(RPRI != None)
        {
            ViewportOwner.GUIController.OpenMenu("TURRPG2.RPGMenu");
            RPGMenu(GUIController(ViewportOwner.GUIController).TopPage()).InitFor(RPRI);
        }
    }
}

exec function RPGSwitch(string NewName) {
    if(RPRI == None)
        FindRPRI();

    if(RPRI != None) {
        RPRI.ServerSwitchBuild(NewName);
    }
}

//Detect pressing of a key bound to one of our aliases
//KeyType() would be more appropriate for what's done here, but Key doesn't seem to work/be set correctly for that function
//which prevents ConsoleCommand() from working on it
function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
    local int n;

    if(Settings.bEnableArtifactRadialMenu)
    {
        if(Action == IST_Release && SelectionArtifact == None)
        {
            if(ViewportOwner.Actor.Pawn != None && static.HasKey(ArtifactUseKey, Key) || (bDefaultArtifactBindings && Key == IK_U))
            {
                if(ArtifactRadialInputTime < ViewportOwner.Actor.Level.TimeSeconds && ArtifactRadialInputTime != 0f)
                {
                    if(SelectedRadialSlot > -1 && ArtifactRadialItems.Length > 0)
                    {
                        RPGGetArtifact(RPGArtifact(ArtifactRadialItems[SelectedRadialSlot]).ArtifactID);
                    }
                    if(bArtifactRadialActive)
                    {
                        bRadialEntering = false;
                        bRadialExiting = true;
                    }
                }
                else if(ArtifactRadialInputTime > ViewportOwner.Actor.Level.TimeSeconds)
                    ViewportOwner.Actor.ActivateItem();

                ArtifactRadialInputTime = 0f;
                bRadialInputChanged = true;
                RadialInputResetTime = ViewportOwner.Actor.Level.TimeSeconds + 0.1f;
                return true;
            }
        }
        else if(bArtifactRadialActive && !bRadialExiting && (Key == IK_MouseX || Key == IK_MouseY))
        {
            if(!ViewportOwner.bWindowsMouseAvailable)
            {
                if(Key == IK_MouseX)
                    MousePosX = FClamp(MousePosX + Delta * (GUIController(ViewportOwner.GUIController).MenuMouseSens) * Settings.ArtifactRadialMenuMouseSens, 0, ResX);
                else
                    MousePosY = FClamp(MousePosY - Delta * (GUIController(ViewportOwner.GUIController).MenuMouseSens) * Settings.ArtifactRadialMenuMouseSens, 0, ResY);
            }
            else
            {
                MousePosX = FClamp(ViewportOwner.WindowsMouseX, 0, ResX);
                MousePosY = FClamp(ViewportOwner.WindowsMouseY, 0, ResY);
            }
            return true;
        }
    }

    if(Action != IST_Press)
        return false;

    if(Settings.bEnableArtifactRadialMenu && (static.HasKey(ArtifactUseKey, Key) || (bDefaultArtifactBindings && Key == IK_U)) && SelectionArtifact == None)
    {
        if(!bRadialInputChanged && ArtifactRadialInputTime == 0f)
        {
            ArtifactRadialInputTime = ViewportOwner.Actor.Level.TimeSeconds + 0.3f;
            RadialSlotTouchTime.Length = 0;
        }
        return true;
    }

    if(SelectionArtifact != None)
    {
        if(Key == IK_Escape)
        {
            SelectionArtifact.ServerCloseSelection();
            SelectionArtifact = None;
            CurrentPage = 0;
            NumPages = 0;
            return true;
        }
        else if(Key == IK_0)
        {
            CurrentPage++;
            if(CurrentPage > NumPages)
                CurrentPage = 0;
            return true;
        }
        else if(Key >= IK_1 && Key <= IK_9)
        {
            n = Key - IK_1;

            n += (9 * CurrentPage);

            if(n < SelectionArtifact.GetNumOptions())
            {
                SelectionArtifact.ServerSelectOption(n);
                SelectionArtifact = None;
                CurrentPage = 0;
                NumPages = 0;
            }

            return true;
        }
    }

    if(bDefaultBindings && Key == IK_L)
    {
        RPGStatsMenu();
        return true;
    }
    else if(bDefaultArtifactBindings && ViewportOwner.Actor.Pawn != None)
    {
        if(Key == IK_U)
        {
            ViewportOwner.Actor.ActivateItem();
            return true;
        }
        else if(Key == IK_LeftBracket)
        {
            ViewportOwner.Actor.PrevItem();
            return true;
        }
        else if(Key == IK_RightBracket)
        {
            if (ViewportOwner.Actor.Pawn != None)
                ViewportOwner.Actor.Pawn.NextItem();

            return true;
        }
    }

    //Don't care about this event, pass it on for further processing
    return false;
}

static final function bool HasKey(array<EInputKey> Keys, EInputKey Key)
{
    local int i;

    for(i = 0; i < Keys.Length; i++)
        if(Key == Keys[i])
            return true;
    return false;
}

function FindRPRI()
{
    local int i;

    if(RPRI != None)
        return;

    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(ViewportOwner.Actor);
    if(RPRI == None)
    {
        Warn("RPGInteraction: Could not find RPRI!");
        return;
    }

    RPRI.Interaction = Self;

    if(RPRI.bImposter)
        return;

    for(i = 0; i < Settings.MyBuilds.Length; i++)
    {
        if(Settings.MyBuilds[i] ~= RPRI.RPGName)
            return;
    }

    Log("Adding" @ RPRI.RPGName @ "to MyBuilds", 'TURRPG2');
    Settings.MyBuilds[Settings.MyBuilds.Length] = RPRI.RPGName;
    Settings.SaveConfig();
}

function ShowSelection(RPGArtifact A)
{
    if(SelectionArtifact != None)
        SelectionArtifact.ServerCloseSelection();

    SelectionArtifact = A;
}

function CloseSelection()
{
    SelectionArtifact = None;
}

function int GetHUDTeamIndex(HudCDeathmatch HUD)
{
    if(HUD.IsA('HudOLTeamDeathmatch')) //OLTeamGames support
        return int(HUD.GetPropertyText("OLTeamIndex"));
    else
        return HUD.TeamIndex;
}

function Color GetHUDTeamColor(HudCDeathmatch HUD)
{
    local int TeamIndex;
    TeamIndex = GetHUDTeamIndex(HUD);

    if(HUD.bUsingCustomHUDColor)
        return HUD.CustomHUDColor;
    if(TeamIndex >= 0 && TeamIndex <= 3)
        return HUDColorTeam[TeamIndex];
    else
        return HUDColorTeam[1];
}

function Color GetHUDTeamTint(HudCDeathmatch HUD)
{
    local Color Color;

    Color = GetHUDTeamColor(HUD);
    Color.R *= 0.5;
    Color.G *= 0.5;
    Color.B *= 0.5;
    Color.A = 100;

    return Color;
}

function DrawArtifactBox(class<RPGArtifact> AClass, RPGArtifact A, Canvas Canvas, HudCDeathmatch HUD, float X, float Y, float Size, optional bool bSelected)
{
    local int Time;
    local float XL, YL, SXL;
    local Color HUDColor;
    local string S;

    Canvas.Style = 5;
    HUDColor = GetHUDTeamColor(HUD);

    if(A != None && A.class == AClass && bSelected)
        Canvas.DrawColor = HUD.HudColorHighlight;
    else
        Canvas.DrawColor = HUDColor;

    Canvas.SetPos(X, Y);
    Canvas.DrawTile(
        ArtifactBorderMaterial,
        Size, Size,
        ArtifactBorderMaterialRect.X,
        ArtifactBorderMaterialRect.Y,
        ArtifactBorderMaterialRect.W,
        ArtifactBorderMaterialRect.H);

    if(AClass.default.IconMaterial != None)
    {
        if(A != None && A.class == AClass && (A.bActive || A == SelectionArtifact))
            Canvas.DrawColor = HUDColor;
        else if(A == None || A.class != AClass || TimeSeconds < A.NextUseTime)
            Canvas.DrawColor = DisabledOverlay;
        else
            Canvas.DrawColor = WhiteColor;

        Canvas.SetPos(X + Size * 0.5 * (1.0 - ArtifactIconInnerScale), Y + Size * 0.5 * (1.0 - ArtifactIconInnerScale));
        Canvas.DrawTile(AClass.default.IconMaterial, Size * ArtifactIconInnerScale, Size * ArtifactIconInnerScale, 0, 0, AClass.default.IconMaterial.MaterialUSize(), AClass.default.IconMaterial.MaterialVSize());
    }

    if(A != None)
    {
        if((A.MaxUses > -1 && A.NumUses < -1) || A.NumCopies > 1)
        {
            //TODO what if we have an artifact with more than one copy but also has more than one use?
            if(A.NumUses > -1 && A.MaxUses > -1)
                S = A.NumUses + (A.default.NumUses * (A.NumCopies - 1)) $ "/" $ A.MaxUses;
            else
                S = string(A.NumCopies);

            Canvas.DrawColor = WhiteColor;
            Canvas.FontScaleX = FontScale.X * 0.65;
            Canvas.FontScaleY = FontScale.Y * 0.65;
            Canvas.TextSize(S, XL, YL);
            Canvas.TextSize("A", SXL, YL);
            Canvas.SetPos((X + Size) - XL - (SXL * 0.2), (Y + Size) - YL - (YL * 0.2));
            Canvas.DrawText(S);

            Canvas.FontScaleX = FontScale.X;
            Canvas.FontScaleY = FontScale.Y;
        }

        if(TimeSeconds < A.NextUseTime)
        {
            Time = int(A.NextUseTime - TimeSeconds) + 1;

            Canvas.DrawColor = WhiteColor;
            Canvas.TextSize(string(Time), XL, YL);
            Canvas.SetPos(X + (Size - XL) * 0.5, Y + (Size - YL) * 0.5);
            Canvas.DrawText(string(Time));
        }
    }
}

function DrawStatusIcon(Canvas Canvas, RPGStatusIcon StatusIcon, float X, float Y, float SizeX, float SizeY)
{
    local string Text;
    local float XL, YL;
    local float IconSize;

    Canvas.Style = 5;

    Canvas.SetPos(X, Y);
    Canvas.DrawColor = WhiteColor;
    Canvas.DrawTile(
        StatusIconBorderMaterial,
        SizeX, SizeY,
        StatusIconBorderMaterialRect.X, StatusIconBorderMaterialRect.Y,
        StatusIconBorderMaterialRect.W, StatusIconBorderMaterialRect.H
    );

    if(StatusIcon.IconMaterial != None)
    {
        IconSize = FMin(SizeX, SizeY) * StatusIconInnerScale;

        Canvas.SetPos(X + (SizeX - IconSize) * 0.5, Y + (SizeY - IconSize) * 0.5);
        Canvas.DrawColor = StatusIconOverlay;
        Canvas.DrawTile(
            StatusIcon.IconMaterial,
            IconSize, IconSize, 0, 0,
            StatusIcon.IconMaterial.MaterialUSize(),
            StatusIcon.IconMaterial.MaterialVSize());
    }

    Text = StatusIcon.GetText();
    if(Text != "")
    {
        Canvas.TextSize(Text, XL, YL);
        Canvas.SetPos(X + (SizeX - XL) * 0.5, Y + (SizeY - YL) * 0.5 + 1);
        Canvas.DrawColor = WhiteColor;
        Canvas.DrawText(Text);
    }
}

function UpdateCanvas(Canvas Canvas)
{
    local float XL, YL;

    CanvasSize.X = Canvas.ClipX;
    CanvasSize.Y = Canvas.ClipY;

    FontScale.X = Canvas.ClipX / 1024.0f;
    FontScale.Y = Canvas.ClipY / 768.0f;

    Canvas.FontScaleX = FontScale.X;
    Canvas.FontScaleY = FontScale.Y;

    Canvas.TextSize(LevelText @ "000", XL, YL);

    ExpBarRect.X = Canvas.ClipX * Settings.ExpBarX;
    ExpBarRect.Y = Canvas.ClipY * Settings.ExpBarY;
    ExpBarRect.W = FMax(XL + 9.0f * FontScale.X, 135.0f * FontScale.X);
    ExpBarRect.H = Canvas.ClipY / 48.0f;

    StatusIconSize.X = default.StatusIconSize.X * Canvas.ClipX / 640.0f;
    StatusIconSize.Y = default.StatusIconSize.Y * Canvas.ClipY / 480.0f;

    StatusIconPos.X = Canvas.ClipX - StatusIconSize.X;
    StatusIconPos.Y = Canvas.ClipY * 0.07f;

    ArtifactIconPos.X = Canvas.ClipX * Settings.IconsX;

    if(Settings.bClassicArtifactSelection)
        ArtifactIconPos.Y = Canvas.ClipY * Settings.IconClassicY;
    else
        ArtifactIconPos.Y = Canvas.ClipY * Settings.IconsY;

    ArtifactIconSize = ArtifactBorderSize * Settings.IconScale * (Canvas.ClipY / 768.0f);
}

function Tick(float DeltaTime)
{
    local int i;
    local int TrySelectedRadialSlot;

    if(!Settings.bEnableArtifactRadialMenu)
        return;

    if(bArtifactRadialActive)
    {
        if(!bRadialExiting && ArtifactRadialItems.Length > 0)
        {
            //test to see if we have this artifact. don't selected it if we don't
            TrySelectedRadialSlot = GetArtifactRadialSelection(MousePosX - (ResX * 0.5), MousePosY - (ResY * 0.5), ArtifactRadialItems.Length);
            if(TrySelectedRadialSlot > -1 && RPGArtifact(ArtifactRadialItems[TrySelectedRadialSlot]) != None)
                SelectedRadialSlot = TrySelectedRadialSlot;
        }
    }

    if(bRadialInputChanged && RadialInputResetTime < ViewportOwner.Actor.Level.TimeSeconds && RadialInputResetTime != 0f)
    {
        bRadialInputChanged = false;
        RadialInputResetTime = 0f;
    }

    if(!bArtifactRadialActive && ArtifactRadialInputTime < ViewportOwner.Actor.Level.TimeSeconds && ArtifactRadialInputTime != 0f)
    {
        bRadialJustChanged = true;
        MousePosX = ResX * 0.5;
        MousePosY = ResY * 0.5;
        SelectedRadialSlot = -1;
        RadialSlotTouchTime.Length = 0;
    }

    if(!bArtifactRadialActive && !bRadialJustChanged)
        return;

    if(bRadialEntering || bRadialJustChanged)
    {
        if(bRadialJustChanged)
        {
            bArtifactRadialActive = true;
            bRadialJustChanged = false;
            bRadialEntering = true;
        }

        RadialTimeAccum = FMin(RadialTimeAccum + DeltaTime * 1.5 * Settings.ArtifactRadialMenuAnimSpeed, 1f);
        if(RadialTimeAccum >= 1f)
            bRadialEntering = false;
    }
    else if(bRadialExiting)
    {
        RadialTimeAccum = FMax(RadialTimeAccum - DeltaTime * 1.5 * Settings.ArtifactRadialMenuAnimSpeed, 0f);
        if(RadialTimeAccum <= 0f)
        {
            bRadialExiting = false;
            bArtifactRadialActive = false;
        }
    }

    if(bArtifactRadialActive)
    {
        CalcRadialSize = ArtifactRadialSize * (ResX / 1920) * RadialTimeAccum;

        for(i = 0; i < RadialSlotTouchTime.Length; i++)
        {
            if(i == SelectedRadialSlot && !bRadialExiting)
                RadialSlotTouchTime[i] = FMin(RadialSlotTouchTime[i] + DeltaTime * 10, 1f);
            else if(RadialSlotTouchTime[i] > 0)
                RadialSlotTouchTime[i] = FMax(RadialSlotTouchTime[i] - DeltaTime * 10, 0f);
        }
    }
    else
        CalcRadialSize = 0;
}

static final function Vec2 GetArtifactRadialPosition(int Slot, int NumArtifacts, float RadialSize, float Time)
{
    local Vec2 Pos;

//  no animation
//  Pos.X = RadialSize * sin((2 * pi * Slot * Time) / NumArtifacts);
//  Pos.Y = -1 * RadialSize * cos((2 * pi * Slot * Time) / NumArtifacts);

//  lerp from top artifact
//  Pos.X = RadialSize * sin((2 * pi * Slot) / (NumArtifacts * Time));
//  Pos.Y = -1 * RadialSize * cos((2 * pi * Slot) / (NumArtifacts * Time));

//  span
//  sqrt(ArtifactRadialSize ^ 2 - (RadialTimeAccum - 1) ^ 2)

    Pos.X = RadialSize * sin(((2 * pi / Clamp(NumArtifacts, 1, 4)) * (Time - 1))  + (2 * pi * Slot) / NumArtifacts);
    Pos.Y = -1 * RadialSize * cos(((2 * pi / Clamp(NumArtifacts, 1, 4)) * (Time - 1))  + (2 * pi * Slot) / NumArtifacts);

    return Pos;
}

static final function int GetArtifactRadialSelection(float MouseX, float MouseY, int NumArtifacts)
{
    local int s;

    if(MouseX == 0 && MouseY == 0)
        return -1;

    s = int(Ceil(((atan(MouseX, MouseY * -1) * NumArtifacts + pi) / (2 * pi)) - 1));
    if(s < 0)
        s = NumArtifacts + s;
    return s;
}

function PostRender(Canvas Canvas)
{
    local float XL, YL, X, Y, CurrentX, CurrentY, Size, SizeX, Fade, MaxWidth, MaxOptionWidth;
    local int i, j, k, l, n, Row, Cost, CurrentOption;
    local string Text;
    local Vec2 RadialArtifactPos;

    local array<class<RPGArtifact> > Artifacts;
    local class<RPGArtifact> AClass;
    local RPGArtifact A;
    local RPGWeaponModifier WM;
    local Pawn P;
    local Material Material;
    local array<string> ExtraParts;
    local array<OptionCostArrayStruct> OptionCosts;
    local array<float> OptionCostWidths;

    local HudCDeathmatch HUD;

    if(ResX != Canvas.ClipX)
        ResX = Canvas.ClipX;
    if(ResY != Canvas.ClipY)
        ResY = Canvas.ClipY;

    if(ViewportOwner == None || ViewportOwner.Actor == None)
        return;

    TimeSeconds = ViewportOwner.Actor.Level.TimeSeconds;

    P = ViewportOwner.Actor.Pawn;
    if(P == None || P.Health <= 0)
    {
        LastSelectedArtifact = None;
        LastSelItemName = "";
        LastSelExtra = "";
        return;
    }

    if(RedeemerWarhead(P) != None)
        return;

    if(RPRI == None)
        FindRPRI();

    if(RPRI == None)
        return;

    HUD = HudCDeathmatch(ViewportOwner.Actor.myHUD);
    if(HUD == None || HUD.bHideHUD || HUD.bShowScoreboard || HUD.bShowLocalStats)
        return;

    if(HUD_Assault(HUD) != None && !HUD_Assault(HUD).ShouldShowObjectiveBoard())
        DrawAdrenaline(Canvas, HUD);

    if(TextFont != None)
        Canvas.Font = TextFont;

    if(bUpdateCanvas || CanvasSize.X != Canvas.ClipX || CanvasSize.Y != Canvas.ClipY)
        UpdateCanvas(Canvas);

    Canvas.FontScaleX = FontScale.X;
    Canvas.FontScaleY = FontScale.Y;

    Canvas.TextSize(LevelText @ RPRI.RPGLevel, XL, YL);

    Canvas.Style = 5; //STY_Alpha

    //Draw artifact radial menu
    if(bArtifactRadialActive)
    {
        Canvas.DrawColor = GetHUDTeamColor(HudCDeathmatch(ViewportOwner.Actor.myHUD));
        Canvas.DrawColor.A = 128;
        Canvas.SetPos((Canvas.ClipX * 0.5) - CalcRadialSize, (Canvas.ClipY * 0.5) - CalcRadialSize);
        Canvas.DrawTile(TexRotator'ArtifactRadial1Rot', CalcRadialSize * 2, CalcRadialSize * 2, 0, 0, 256, 256);
        Canvas.SetPos((Canvas.ClipX * 0.5) - CalcRadialSize, (Canvas.ClipY * 0.5) - CalcRadialSize);
        Canvas.DrawTile(TexRotator'ArtifactRadial2Rot', CalcRadialSize * 2, CalcRadialSize * 2, 0, 0, 256, 256);

        Canvas.DrawColor = WhiteColor;

        //TODO: optimize this. completely unnecessary to do loops this big in rendering code
        ArtifactRadialItems.Length = 0;
        for(i = 0; i < RPRI.ArtifactRadialMenuOrder.Length; i++)
        {
            A = RPGArtifact(P.FindInventoryType(RPRI.ArtifactRadialMenuOrder[i].ArtifactClass));
            if(A != None)
                ArtifactRadialItems[ArtifactRadialItems.Length] = A;
            else if(RPRI.ArtifactRadialMenuOrder[i].bShowAlways)
                ArtifactRadialItems[ArtifactRadialItems.Length] = RPRI.ArtifactRadialMenuOrder[i].ArtifactClass;
        }
        RadialSlotTouchTime.Length = ArtifactRadialItems.Length;

        for(i = 0; i < ArtifactRadialItems.Length; i++)
        {
            RadialArtifactPos = GetArtifactRadialPosition(i, ArtifactRadialItems.Length, CalcRadialSize * 0.9, RadialTimeAccum);

            if(RadialSlotTouchTime[i] > 0)
            {
                Canvas.DrawColor = WhiteColor;
                Canvas.DrawColor.A = 200;
                Canvas.SetPos(Canvas.ClipX * 0.5 + RadialArtifactPos.X - (64 * RadialSlotTouchTime[i]) * (ResX / 1920), Canvas.ClipY * 0.5 + (RadialArtifactPos.Y) - (64 * RadialSlotTouchTime[i]) * (ResX / 1920));
                Canvas.DrawTile(Texture'GlowCircle', 128 * RadialSlotTouchTime[i] * (ResX / 1920), 128 * RadialSlotTouchTime[i] * (ResX / 1920), 0, 0, 64, 64);
            }

            Canvas.SetPos(Canvas.ClipX * 0.5 + RadialArtifactPos.X - (32 * RadialTimeAccum) * (ResX / 1920), Canvas.ClipY * 0.5 + RadialArtifactPos.Y - (32 * RadialTimeAccum) * (ResX / 1920));
            if(RPGArtifact(ArtifactRadialItems[i]) != None)
            {
                Canvas.DrawColor = WhiteColor;
                Material = RPGArtifact(ArtifactRadialItems[i]).IconMaterial;
            }
            else
            {
                Canvas.DrawColor = DisabledOverlay;
                Material = class<RPGArtifact>(ArtifactRadialItems[i]).default.IconMaterial;
            }
            Canvas.DrawTile(Material, 64 * RadialTimeAccum * (ResX / 1920), 64 * RadialTimeAccum * (ResX / 1920), 0, 0, Material.MaterialUSize(), Material.MaterialVSize());
        }

        if(!bRadialExiting)
        {
            // Draw mouse pointer.
            Canvas.DrawColor = WhiteColor;
            Canvas.SetPos(MousePosX, MousePosY);
            Canvas.DrawIcon(Texture'Pointer', 1);
        }
    }

    //Draw exp bar
    if(!Settings.bHideExpBar)
    {
        if(Settings.XPHudStyle == 0) //Classic style
        {
            //Progress
            Canvas.DrawColor = EXPBarColor;
            Canvas.SetPos(ExpBarRect.X, ExpBarRect.Y);

            if(RPRI.NeededExp > 0) {
                XL = RPRI.Experience / RPRI.NeededExp;
                Canvas.DrawTile(
                    Material'InterfaceContent.Hud.SkinA',
                    ExpBarRect.W * XL,
                    15.0f * Canvas.FontScaleY,
                    836, 454, -386 * XL, 36);
            }

            //Tint
            Canvas.DrawColor = GetHUDTeamTint(HUD);
            Canvas.SetPos(ExpBarRect.X, ExpBarRect.Y);
            Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', ExpBarRect.W, ExpBarRect.H * 0.9375f, 836, 454, -386, 36);

            //Border
            Canvas.DrawColor = WhiteColor;
            Canvas.SetPos(ExpBarRect.X, ExpBarRect.Y);
            Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', ExpBarRect.W, ExpBarRect.H, 836, 415, -386, 38);

            //Level Text
            Text = LevelText @ RPRI.RPGLevel;
            Canvas.TextSize(Text, XL, YL);
            Canvas.SetPos(ExpBarRect.X + 0.5 * (ExpBarRect.W - XL), ExpBarRect.Y - YL);
            Canvas.DrawText(Text);

            //Experience Text
            Canvas.FontScaleX *= 0.75;
            Canvas.FontScaleY *= 0.75;

            if(RPRI.NeededExp > 0) {
                Text = int(RPRI.Experience) $ "/" $ RPRI.NeededExp;
            } else {
                Text = string(int(RPRI.Experience));
            }

            Canvas.TextSize(Text, XL, YL);
            Canvas.SetPos(ExpBarRect.X + 0.5 * (ExpBarRect.W - XL), ExpBarRect.Y + 0.5 * (ExpBarRect.H - YL) + 1);
            Canvas.DrawText(Text);

            //Experience Gain
            if(!Settings.bHideExpGain && Settings.ExpGainDuration > 0 &&
                (Settings.ExpGainDuration >= ExpGainDurationForever || ExpGainTimer > TimeSeconds))
            {
                if(ExpGain >= 0)
                {
                    Text = "+" $ class'Util'.static.FormatFloat(ExpGain);
                    Canvas.DrawColor = WhiteColor;
                }
                else
                {
                    Text = class'Util'.static.FormatFloat(ExpGain);
                    Canvas.DrawColor = RedColor;
                }

                if(Settings.ExpGainDuration < ExpGainDurationForever)
                {
                    Fade = ExpGainTimer - TimeSeconds;
                    if(Fade <= 1.0f)
                        Canvas.DrawColor.A = 255 * Fade;
                }

                Canvas.TextSize(Text, XL, YL);
                Canvas.SetPos(ExpBarRect.X + 0.5 * (ExpBarRect.W - XL), ExpBarRect.Y + ExpBarRect.H + 1);
                Canvas.DrawText(Text);
            }

            //Reset
            Canvas.FontScaleX = FontScale.X;
            Canvas.FontScaleY = FontScale.Y;
        }
        else if(Settings.XPHudStyle == 1) //SAO style
        {
            Canvas.Font = GetMediumSAOFontFor(Canvas);
            Canvas.FontScaleX *= 0.3;
            Canvas.FontScaleY *= 0.3;

            //Progress
            Canvas.DrawColor = WhiteColor;
            Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 5.836053), ExpBarRect.Y + (ExpBarRect.H * 0.918032));

            if(RPRI.NeededExp > 0) {
                XL = RPRI.Experience / RPRI.NeededExp;

                if(264 * XL <= 12)
                {
                    Canvas.DrawTile(
                        Material'SAOHud',
                        ExpBarRect.H * 17.311453 * XL,
                        ExpBarRect.H * 1.180328,
                        28 - (264 * XL), 108, 264 * XL, 18);
                }
                else if(XL <= 0.545454)
                {
                    if(XL < 0.25)
                    {
                        //Full part
                        Canvas.DrawTile(
                            Material'SAOHud',
                            (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.786878),
                            ExpBarRect.H * 1.180328,
                            64, 108, (264 * XL) - 12, 18);

                        //Slanted head
                        Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 5.836053) + (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.786878) - 1, ExpBarRect.Y + (ExpBarRect.H * 0.918032));
                        Canvas.DrawTile(
                            Material'SAOHud',
                            ExpBarRect.H * 0.786878,
                            ExpBarRect.H * 1.180328,
                            16, 108, 12, 18);
                    }
                    else if(XL < 0.5)
                    {
                        //Full part
                        Canvas.DrawTile(
                            Material'SAOHud',
                            (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.786878),
                            ExpBarRect.H * 1.180328,
                            64, 86, (264 * XL) - 12, 18);

                        //Slanted head
                        Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 5.836053) + (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.786878) - 1, ExpBarRect.Y + (ExpBarRect.H * 0.918032));
                        Canvas.DrawTile(
                            Material'SAOHud',
                            ExpBarRect.H * 0.786878,
                            ExpBarRect.H * 1.180328,
                            16, 86, 12, 18);
                    }
                    else
                    {
                        //Full part
                        Canvas.DrawTile(
                            Material'SAOHud',
                            (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.786878),
                            ExpBarRect.H * 1.180328,
                            64, 64, (264 * XL) - 12, 18);

                        //Slanted head
                        Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 5.836053) + (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.786878) - 1, ExpBarRect.Y + (ExpBarRect.H * 0.918032));
                        Canvas.DrawTile(
                            Material'SAOHud',
                            ExpBarRect.H * 0.786878,
                            ExpBarRect.H * 1.180328,
                            16, 64, 12, 18);
                    }
                }
                else
                {
                    //Full part
                    Canvas.DrawTile(
                        Material'SAOHud',
                        (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.459000),
                        ExpBarRect.H * 1.180328,
                        64, 64, (264 * XL) - 7, 18);

                    //Slanted head
                    Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 5.836053) + (ExpBarRect.H * 17.311453 * XL) - (ExpBarRect.H * 0.459000) - 1, ExpBarRect.Y + (ExpBarRect.H * 0.918032));
                    Canvas.DrawTile(
                        Material'SAOHud',
                        ExpBarRect.H * 0.459000,
                        ExpBarRect.H * 1.180328,
                        321, 64, 7, 18);
                }
            }

            //Border
            Canvas.DrawColor = WhiteColor;
            Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14), ExpBarRect.Y);
            Canvas.DrawTile(Material'SAOHud', ExpBarRect.H * 4 * 6.213115, ExpBarRect.H * 4, 0, 0, 379, 61);

            //Level Text
            Text = "LV:" $ RPRI.RPGLevel;
            Canvas.TextSize(Text, XL, YL);
            Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 22.557385) - (XL * 0.5), ExpBarRect.Y + (ExpBarRect.H * 3.081968) - (YL * 0.5));
            Canvas.DrawText(Text);

            //Experience Text
            if(RPRI.NeededExp > 0) {
                Text = int(RPRI.Experience) @ "/" @ RPRI.NeededExp;
            } else {
                Text = string(int(RPRI.Experience));
            }

            Canvas.TextSize(Text, XL, YL);
            Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 18.491795) - (XL * 0.5), ExpBarRect.Y + (ExpBarRect.H * 3.081968) - (YL * 0.5));
            Canvas.DrawText(Text);

            //Experience Gain
            if(!Settings.bHideExpGain && Settings.ExpGainDuration > 0 &&
                (Settings.ExpGainDuration >= ExpGainDurationForever || ExpGainTimer > TimeSeconds))
            {
                if(ExpGain >= 0)
                {
                    Text = "+" $ class'Util'.static.FormatFloat(ExpGain);
                    Canvas.DrawColor = WhiteColor;
                }
                else
                {
                    Text = class'Util'.static.FormatFloat(ExpGain);
                    Canvas.DrawColor = RedColor;
                }

                if(Settings.ExpGainDuration < ExpGainDurationForever)
                {
                    Fade = ExpGainTimer - TimeSeconds;
                    if(Fade <= 1.0f)
                        Canvas.DrawColor.A = 255 * Fade;
                }

                Canvas.TextSize(Text, XL, YL);
                Canvas.SetPos(ExpBarRect.X - (ExpBarRect.H * 14) + (ExpBarRect.H * 4.000003) - (XL * 0.5), ExpBarRect.Y + (ExpBarRect.H * 1.5) - (YL * 0.5));
                Canvas.DrawText(Text);
            }

            //Reset
            if(TextFont != None)
                Canvas.Font = TextFont;
            else
                Canvas.Font = Canvas.default.Font;
            Canvas.FontScaleX = FontScale.X;
            Canvas.FontScaleY = FontScale.Y;
        }
    }

    //Draw linkers indicator for vehicles
    if(Vehicle(ViewportOwner.Actor.Pawn) != None && RPRI.NumVehicleHealers > 0)
    {
        Canvas.TextSize("200", XL, YL);
        Canvas.SetPos(Canvas.ClipX - XL * 1.5, Canvas.ClipY * 0.8);

        Canvas.Style = 5; //STY_Alpha
        Canvas.DrawColor = WhiteColor;
        Canvas.DrawTile(Material'HUDContent.Generic.fbLinks', XL, XL * 0.5, 0, 0, 128, 64);

        Text = string(RPRI.NumVehicleHealers);
        Canvas.SetPos(Canvas.ClipX - XL * 1.125, (Canvas.ClipY * 0.8) + XL * 0.125);
        Canvas.DrawColor = Canvas.MakeColor(159, 255, 159);
        Canvas.DrawText(Text);
    }

    //Draw hints
    if(Hint.Length > 0 && HintTimer > TimeSeconds && (HUD_Assault(HUD) == None || !HUD_Assault(HUD).ShouldShowObjectiveBoard()))
    {
        Canvas.DrawColor = HintColor;

        Fade = HintTimer - TimeSeconds;
        if(Fade <= 1.0f)
            Canvas.DrawColor.A = 255 * Fade;

        Y = Canvas.ClipY * 0.1f;
        for(i = 0; i < Hint.Length; i++)
        {
            Canvas.TextSize(Hint[i], XL, YL);
            Canvas.SetPos(Canvas.ClipX - XL - 1, Y);
            Canvas.DrawText(Hint[i]);

            Y += YL;
        }
    }

    //From here on, only if there's still a game going on... should reduce the crashes
    if(!RPRI.bGameEnded)
    {
        //Draw status icons
        if(
            !Settings.bHideStatusIcon &&
            (HUD_Assault(HUD) == None || !HUD_Assault(HUD).ShouldShowObjectiveBoard())
        )
        {
            Canvas.FontScaleX *= 0.7f * Settings.StatusScale;
            Canvas.FontScaleY *= 0.7f * Settings.StatusScale;

            X = StatusIconPos.X;
            Y = StatusIconPos.Y;

            for(i = 0; i < RPRI.Status.Length; i++)
            {
                if(RPRI.Status[i] != None && RPRI.Status[i].IsVisible())
                {
                    DrawStatusIcon(Canvas, RPRI.Status[i], X, Y, StatusIconSize.X * Settings.StatusScale, StatusIconSize.Y * Settings.StatusScale);
                    X -= StatusIconSize.X * Settings.StatusScale;
                }
            }

            //Reset
            Canvas.FontScaleX = FontScale.X;
            Canvas.FontScaleY = FontScale.Y;
        }

        //Draw artifacts
        if(Settings.bClassicArtifactSelection)
        {
            //Classic Selection
            A = RPGArtifact(P.SelectedItem);
            if(A != None)
            {
                //Name
                Canvas.TextSize(A.ItemName, XL, YL);

                if(Settings.IconsX > 0.85f)
                    X = ArtifactIconPos.X + ArtifactIconSize - XL;
                else if(Settings.IconsX < 0.15f)
                    X = ArtifactIconPos.X;
                else
                    X = ArtifactIconPos.X + ArtifactIconSize - XL * 0.5f;

                if(Settings.IconClassicY < 0.25f)
                    Y = ArtifactIconPos.Y + ArtifactIconSize + 1;
                else
                    Y = ArtifactIconPos.Y - YL - 1;

                Canvas.DrawColor = WhiteColor;
                Canvas.SetPos(X, Y);
                Canvas.DrawText(A.ItemName);

                //Icon
                DrawArtifactBox(
                    A.class, A, Canvas, HUD, ArtifactIconPos.X, ArtifactIconPos.Y, ArtifactIconSize);
            }
        }
        else
        {
            Size = ArtifactIconSize;

            i = Min(Settings.IconsPerRow, Artifacts.Length);
            if(i > 10)
                Size /= float(i) * 0.1;

            CurrentX = ArtifactIconPos.X;
            CurrentY = ArtifactIconPos.Y;

            for(i = 0; i < RPRI.ArtifactOrder.Length; i++)
            {
                AClass = RPRI.ArtifactOrder[i].ArtifactClass;
                A = RPGArtifact(P.FindInventoryType(AClass));

                if(AClass != None && !RPRI.ArtifactOrder[i].bNeverShow && ((A != None && A.class == AClass) || RPRI.ArtifactOrder[i].bShowAlways))
                {
                    if(++Row > Settings.IconsPerRow)
                    {
                        Row = 1;

                        CurrentX += (1.f + ArtifactHighlightIndention) * Size;
                        CurrentY = ArtifactIconPos.Y;
                    }

                    X = CurrentX;
                    Y = CurrentY;

                    if(A != None && A.class == AClass && A == P.SelectedItem)
                    {
                        if(Settings.IconsPerRow > 1)
                        {
                            if(Settings.IconsX > 0.85)
                                X -= ArtifactHighlightIndention * Size;
                            else if(Settings.IconsX < 0.15)
                                X += ArtifactHighlightIndention * Size;
                        }
                        else
                        {
                            if(Settings.IconsY > 0.75)
                                Y -= ArtifactHighlightIndention * Size;
                            else if(Settings.IconsY < 0.25)
                                Y += ArtifactHighlightIndention * Size;
                        }
                    }

                    DrawArtifactBox(AClass, A, Canvas, HUD, X, Y, Size, A != None && A.class == AClass && A == P.SelectedItem);
                    CurrentY += Size;
                }
            }
        }

        //Solve Weapon extra / Artiface name conflict
        if(!Settings.bHideArtifactName && !HUD.bHideWeaponName &&
            HUD.WeaponDrawTimer > TimeSeconds &&
            ArtifactDrawTimer > TimeSeconds)
        {
            if(ArtifactDrawTimer > HUD.WeaponDrawTimer)
                HUD.WeaponDrawTimer = 0;
            else
                ArtifactDrawTimer = 0;
        }

        //Draw artifact name
        if(!Settings.bHideArtifactName && LastSelectedArtifact != None && ArtifactDrawTimer > TimeSeconds)
        {
            Canvas.Font = HUD.GetMediumFontFor(Canvas);
            Canvas.FontScaleX = Canvas.default.FontScaleX;
            Canvas.FontScaleY = Canvas.default.FontScaleY;

            Fade = ArtifactDrawTimer - TimeSeconds;

            Canvas.DrawColor = ArtifactDrawColor;
            if(Fade <= 1.0f)
                Canvas.DrawColor.A = 255.0f * Fade;

            Canvas.TextSize(LastSelItemName, XL, YL);

            Canvas.SetPos((Canvas.ClipX - XL) * 0.5f, Canvas.ClipY * 0.8f - YL);
            Canvas.DrawText(LastSelItemName);

            //Artifact extra
            if(!Settings.bHideWeaponExtra)
            {
                if(LastSelExtra != "")
                {
                    Canvas.FontScaleX = Canvas.default.FontScaleX * 0.6f;
                    Canvas.FontScaleY = Canvas.default.FontScaleY * 0.6f;

                    Canvas.WrapStringToArray(LastSelExtra, ExtraParts, Canvas.ClipX, "|");

                    if(ExtraParts.Length == 1)
                    {
                        Canvas.TextSize(LastSelExtra, XL, YL);
                        Canvas.SetPos((Canvas.ClipX - XL) * 0.5f, Canvas.ClipY * 0.8f);
                        Canvas.DrawText(LastSelExtra);
                    }
                    else
                    {
                        for(i = 0; i < ExtraParts.Length; i++)
                        {
                            Canvas.TextSize(ExtraParts[i], XL, YL);
                            Canvas.SetPos((Canvas.ClipX - XL) * 0.5, (Canvas.ClipY * 0.8) + (YL * i));
                            Canvas.DrawText(ExtraParts[i]);
                        }
                    }
                }
            }
        }
        else
        {
            if(!Settings.bHideWeaponExtra && !HUD.bHideWeaponName)
            {
                //Get new description
                if(P.PendingWeapon != None)
                {
                    WM = class'RPGWeaponModifier'.static.GetFor(P.PendingWeapon);
                    if(WM != None)
                        LastWeaponExtra = WM.GetDescription();
                    else
                        LastWeaponExtra = "";
                }

                //Draw weapon extra
                if(LastWeaponExtra != "" && HUD.WeaponDrawTimer > TimeSeconds)
                {
                    Canvas.Font = HUD.GetMediumFontFor(Canvas);
                    Canvas.FontScaleX = Canvas.default.FontScaleX * 0.6;
                    Canvas.FontScaleY = Canvas.default.FontScaleY * 0.6;

                    Fade = HUD.WeaponDrawTimer - TimeSeconds;

                    Canvas.DrawColor = HUD.WeaponDrawColor;
                    if(Fade <= 1.0f)
                        Canvas.DrawColor.A = 255.0f * Fade;

                    Canvas.WrapStringToArray(LastWeaponExtra, ExtraParts, Canvas.ClipX, "|");

                    if(ExtraParts.Length == 1)
                    {
                        Canvas.TextSize(LastWeaponExtra, XL, YL);
                        Canvas.SetPos((Canvas.ClipX - XL) * 0.5f, Canvas.ClipY * 0.8f);
                        Canvas.DrawText(LastWeaponExtra);
                    }
                    else
                    {
                        for(i = 0; i < ExtraParts.Length; i++)
                        {
                            Canvas.TextSize(ExtraParts[i], XL, YL);
                            Canvas.SetPos((Canvas.ClipX - XL) * 0.5, (Canvas.ClipY * 0.8) + (YL * i));
                            Canvas.DrawText(ExtraParts[i]);
                        }
                    }
                }
            }
        }

        //Get newest artifact
        if(!Settings.bHideArtifactName &&
            RPGArtifact(P.SelectedItem) != None &&
            P.SelectedItem.class != LastSelectedArtifact)
        {
            ArtifactDrawTimer = TimeSeconds + 1.5;
            LastSelectedArtifact = RPGArtifact(P.SelectedItem).class;
            LastSelItemName = RPGArtifact(P.SelectedItem).ItemName;
            LastSelExtra = class<RPGArtifact>(P.SelectedItem.class).static.GetArtifactNameExtra();
            ArtifactDrawColor = RPGArtifact(P.SelectedItem).HudColor;

            HUD.WeaponDrawTimer = 0; //do not display weapon name anymore
        }
        else if(RPGArtifact(P.SelectedItem) == None)
        {
            LastSelectedArtifact = None;
            LastSelItemName = "";
            LastSelExtra = "";
        }

        //Weapon Modifier
        WM = class'RPGWeaponModifier'.static.GetFor(P.Weapon);
        if(WM != None)
            WM.PostRender(Canvas);
    }

    //Draw Artifact Selection
    if(SelectionArtifact != None)
    {
        NumPages = 0;
        n = SelectionArtifact.GetNumOptions();
        if(n > 9)
        {
            do
            {
                NumPages++;
                n -= 9;
            } until(n < 10);
            n = 10;
        }
        if(CurrentPage == 0)
            StartOption = 0;
        else
            StartOption = (9 * CurrentPage);

        Canvas.Font = HUD.GetMediumFontFor(Canvas);
        Canvas.FontScaleX = 0.5f;
        Canvas.FontScaleY = 0.5f;
        Canvas.DrawColor = WhiteColor;

        //Determine sizing before drawing and scale the window to compensate

        for(i = 0; i < SelectionArtifact.GetNumOptions(); i++)
        {
            j = OptionCosts.Length;
            OptionCosts.Length = j + 1;
            OptionCosts[j].Arr = SelectionArtifact.GetHUDOptionCosts(i);

            if(OptionCosts[j].Arr.Length > 0)
            {
                for(k = 0; k < OptionCosts[j].Arr.Length; k++)
                {
                    Canvas.TextSize(OptionCosts[j].Arr[k].Cost, XL, YL);

                    if(k >= OptionCostWidths.Length)
                    {
                        l = OptionCostWidths.Length;
                        OptionCostWidths.Length = l + 1;
                    }
                    else
                        l = k;
                    if(OptionCostWidths[l] < XL)
                        OptionCostWidths[l] = XL;
                }
            }
            else
            {
                Canvas.TextSize(SelectionArtifact.GetOptionCost(i), XL, YL);
                if(MaxOptionWidth < XL)
                    MaxOptionWidth = XL;
            }
        }
        if(MaxOptionWidth == 0)
        {
            if(OptionCostWidths.Length > 0)
            {
                for(i = 0; i < OptionCostWidths.Length; i++)
                {
                    MaxOptionWidth += OptionCostWidths[i];
                    for(j = i + 1; j < OptionCostWidths.Length; j++)
                        OptionCostWidths[i] += OptionCostWidths[j];
                }
            }
        }

        //Option strings sizes
        for(i = 0; i < SelectionArtifact.GetNumOptions(); i++)
        {
            Canvas.TextSize(i @ "-" @ SelectionArtifact.GetOption(i) @ SelectionArtifact.GetOptionCost(i), CurrentX, CurrentY);
            MaxWidth = FMax(MaxWidth, CurrentX + XL + MaxOptionWidth + OptionCostWidths.Length * YL);
        }

        //Next page option text, but leave room for option costs so it's not too crowded
        Canvas.TextSize("0 -" @ ArtifactMoreOptionsText, XL, YL);
        MaxWidth = FMax(MaxWidth, XL + MaxOptionWidth);

        //Title string size
        Text = SelectionArtifact.GetSelectionTitle();
        Canvas.TextSize(Text, XL, YL);
        MaxWidth = FMax(MaxWidth, XL);

        //Start drawing
        SizeX = FMax(300, MaxWidth) + YL * 2;
        Size = YL * float(n + 2) + 3;
        X = (Canvas.ClipX - SizeX) * 0.5f;
        Y = (Canvas.ClipY - Size) * 0.5f;

        Canvas.SetPos(X, Y);
        Canvas.DrawTileStretched(Texture'InterfaceContent.Menu.BorderBoxD', SizeX, Size);

        if(SelectionArtifact.IconMaterial != None)
        {
            Canvas.SetPos(X + SizeX - YL * 3.5f, Y + Size - YL * 3.5);
            Canvas.DrawColor = WhiteTrans;
            Canvas.DrawTile(
                SelectionArtifact.IconMaterial,
                YL * 3.0f, YL * 3.0f,
                0, 0,
                SelectionArtifact.IconMaterial.MaterialUSize(),
                SelectionArtifact.IconMaterial.MaterialVSize());

            Canvas.DrawColor = WhiteColor;
        }

        X += YL * 0.5f;
        Y += YL * 0.5f;

        Canvas.SetPos(X - 2, Y - 3);
        Canvas.DrawTileStretched(Texture'InterfaceContent.Menu.SquareBoxA', SizeX - YL, YL + 4);

        Canvas.SetPos(X, Y);
        Canvas.DrawTextClipped(Text);
        Y += YL + 3;

        //Draw option strings
        for(i = 0; i < n; i++) {
            CurrentOption = StartOption + i;
            if((i == 9 || i == n) && (i != 0 && NumPages > 0))
            {
                Text = "0 -" @ ArtifactMoreOptionsText;
                Canvas.DrawColor = WhiteColor;
            }
            else if(CurrentOption > SelectionArtifact.GetNumOptions() - 1)
            {
                Text = string(i + 1) @ "-" @ ArtifactNAText;
                Canvas.DrawColor = DisabledOverlay;
            }
            else
            {
                Text = string(i + 1) @ "-" @ SelectionArtifact.GetOption(CurrentOption);
                Canvas.TextSize(Text, CurrentX, CurrentY);

                Canvas.DrawColor = WhiteColor;
                if(OptionCosts[CurrentOption].Arr.Length > 0)
                {
                    for(j = 0; j < OptionCosts[CurrentOption].Arr.Length; j++)
                    {
                        if(!OptionCosts[CurrentOption].Arr[j].bCanAfford)
                        {
                            Canvas.DrawColor = DisabledOverlay;
                            break;
                        }
                    }
                }
                else
                {
                    Cost = SelectionArtifact.GetOptionCost(CurrentOption);
                    if(Cost > 0 && ViewportOwner.Actor.Adrenaline < Cost)
                        Canvas.DrawColor = DisabledOverlay;
                }
            }

            Canvas.SetPos(X, Y);
            Canvas.DrawTextClipped(Text);

            Y += YL;
        }

        //Draw option costs
        X += SizeX - YL;
        Y -= n * YL;
        for(i = 0; i < n; i++) {
            CurrentOption = StartOption + i;
            if(!((i == 9 && i != 0 && NumPages > 0) || CurrentOption > SelectionArtifact.GetNumOptions() - 1))
            {
                if(CurrentOption < SelectionArtifact.GetNumOptions() && OptionCosts[CurrentOption].Arr.Length > 0)
                {
                    for(j = 0; j < OptionCosts[CurrentOption].Arr.Length; j++)
                    {
                        Canvas.DrawColor = WhiteColor;

                        Canvas.SetPos(X - OptionCostWidths[j] - YL * (OptionCostWidths.Length - j), Y);
                        if(OptionCosts[CurrentOption].Arr[j].X1 == 0
                        && OptionCosts[CurrentOption].Arr[j].Y1 == 0
                        && OptionCosts[CurrentOption].Arr[j].X2 == 0
                        && OptionCosts[CurrentOption].Arr[j].Y2 == 0)
                        {
                            Canvas.DrawTileClipped(
                                OptionCosts[CurrentOption].Arr[j].Icon,
                                YL, YL,
                                0,
                                0,
                                OptionCosts[CurrentOption].Arr[j].Icon.MaterialUSize(),
                                OptionCosts[CurrentOption].Arr[j].Icon.MaterialVSize());
                        }
                        else
                        {
                            Canvas.DrawTileClipped(
                                OptionCosts[CurrentOption].Arr[j].Icon,
                                YL, YL,
                                OptionCosts[CurrentOption].Arr[j].X1,
                                OptionCosts[CurrentOption].Arr[j].Y1,
                                OptionCosts[CurrentOption].Arr[j].X2,
                                OptionCosts[CurrentOption].Arr[j].Y2);
                        }

                        if(!OptionCosts[CurrentOption].Arr[j].bCanAfford) {
                            Canvas.DrawColor = RedColor;
                        }

                        Canvas.SetPos(X - OptionCostWidths[j] - YL * (OptionCostWidths.Length - 1 - j), Y);
                        Canvas.DrawTextClipped(string(OptionCosts[CurrentOption].Arr[j].Cost));
                    }
                }
                else
                {
                    Cost = SelectionArtifact.GetOptionCost(CurrentOption);
                    if(Cost > 0) {
                        Canvas.DrawColor = WhiteColor;

                        Canvas.SetPos(X - YL - MaxOptionWidth, Y);
                        Canvas.DrawTileClipped(
                            Material'HUDContent.Generic.HUD',
                            YL, YL,
                            113, 38, 52, 68);

                        if(ViewportOwner.Actor.Adrenaline < Cost) {
                            Canvas.DrawColor = RedColor;
                        }

                        Canvas.SetPos(X - MaxOptionWidth, Y);
                        Canvas.DrawTextClipped(string(Cost));
                    }
                }
            }

            Y += YL;
        }
    }

    //Reset
    Canvas.DrawColor = Canvas.default.DrawColor;
    Canvas.Font = Canvas.default.Font;
    Canvas.FontScaleX = Canvas.default.FontScaleX;
    Canvas.FontScaleY = Canvas.default.FontScaleY;
}

//draw adrenaline (for assault hud)
function DrawAdrenaline(Canvas C, HudCDeathMatch HUD)
{
    if(!HUD.PlayerOwner.bAdrenalineEnabled)
        return;

    HUD.DrawSpriteWidget(C, HUD.AdrenalineBackground);
    HUD.DrawSpriteWidget(C, HUD.AdrenalineBackgroundDisc);

    if(HUD.CurEnergy == HUD.MaxEnergy)
    {
        HUD.DrawSpriteWidget(C, HUD.AdrenalineAlert);
        HUD.AdrenalineAlert.Tints[HUD.TeamIndex] = HUD.HudColorHighLight;
    }

    HUD.DrawSpriteWidget(C, HUD.AdrenalineIcon);
    HUD.DrawNumericWidget( C, HUD.AdrenalineCount, HUD.DigitsBig);

    if(HUD.CurEnergy > HUD.LastEnergy)
        HUD.LastAdrenalineTime = HUD.Level.TimeSeconds;

    HUD.LastEnergy = HUD.CurEnergy;
    HUD.DrawHUDAnimWidget(HUD.AdrenalineIcon, HUD.default.AdrenalineIcon.TextureScale, HUD.LastAdrenalineTime, 0.6, 0.6);
    HUD.AdrenalineBackground.Tints[HUD.TeamIndex] = HUD.HudColorBlack;
    HUD.AdrenalineBackground.Tints[HUD.TeamIndex].A = 150;
}

function NotifyExpGain(float Amount)
{
    if(Settings.ExpGainDuration >= ExpGainDurationForever || ExpGainTimer > ViewportOwner.Actor.Level.TimeSeconds)
        ExpGain += Amount;
    else
        ExpGain = Amount;

    ExpGainTimer = ViewportOwner.Actor.Level.TimeSeconds + Settings.ExpGainDuration;
}

function ShowHint(string Text)
{
    Split(Text, "|", Hint);
    HintTimer = ViewportOwner.Actor.Level.TimeSeconds + HintDuration;
}

//New function to select a specific artifact!
exec function GetArtifact(string ArtifactID)
{
    if(RPRI != None)
        RPRI.ServerGetArtifact(ArtifactID);
}

//Compability for ONS RPG
exec function RPGGetArtifact(string ArtifactID)
{
    if(RPRI != None)
        RPRI.ServerGetArtifact(ArtifactID);
}

//Directly activate an artifact without having to select it
exec function RPGActivateArtifact(string ArtifactID)
{
    if(RPRI != None)
        RPRI.ServerActivateArtifact(ArtifactID);
}

exec function KillMonsters()
{
    if(RPRI != None)
        RPRI.ServerKillMonsters();
}

exec function KillTurrets()
{
    if(RPRI != None)
        RPRI.ServerDestroyTurrets();
}

exec function RPGFavoriteWeapon()
{
    local RPGWeaponModifier Modifier;
    local bool bIsFavorite;

    if(ViewportOwner.Actor.Pawn == None && ViewportOwner.Actor.Pawn.Weapon == None || RPRI == None)
        return;

    Modifier = class'RPGWeaponModifier'.static.GetFor(ViewportOwner.Actor.Pawn.Weapon, true);

    if(Modifier != None)
    {
        bIsFavorite = RPRI.IsFavorite(Modifier.Weapon.Class, Modifier.Class);
        if(!bIsFavorite)
            RPRI.AddFavorite(ViewportOwner.Actor.Pawn.Weapon.Class, Modifier.Class);
        else
            RPRI.RemoveFavorite(ViewportOwner.Actor.Pawn.Weapon.Class, Modifier.Class);
    }
}

exec function LockVehicle()
{
    if(Vehicle(ViewportOwner.Actor.Pawn) != None && RPRI.LockVehicle(Vehicle(ViewportOwner.Actor.Pawn)))
    {
        ViewportOwner.Actor.ClientPlaySound(VehicleLockSound,, 1);
        ViewportOwner.Actor.ClientMessage(VehicleLockedMessage);
    }
}

exec function UnlockVehicle()
{
    if(Vehicle(ViewportOwner.Actor.Pawn) != None && RPRI.UnlockVehicle(Vehicle(ViewportOwner.Actor.Pawn)))
    {
        ViewportOwner.Actor.ClientPlaySound(VehicleUnlockSound,, 1);
        ViewportOwner.Actor.ClientMessage(VehicleUnlockedMessage);
    }
}

event NotifyLevelChange()
{
    FindRPRI();

    if(RPRI != None && RPRI.Level.Game != None)
    {
        if(class'MutTURRPG'.static.Instance(RPRI.Level) != None)
            class'MutTURRPG'.static.Instance(RPRI.Level).SaveData();
    }

    Remove();
}

function Remove()
{
    if(RPRI.Menu != None)
        GUIController(ViewportOwner.GUIController).RemoveMenu(RPRI.Menu);

    SelectionArtifact = None;
    RPRI = None;
    Settings = None;
    CharSettings = None;

    Master.RemoveInteraction(Self);
}

exec function ListChannels()
{
    local int n;
    local Actor A;

    foreach ViewportOwner.Actor.DynamicActors(class'Actor', A)
    {
        if(A.RemoteRole == ROLE_Authority)
        {
            Log(A, 'Channels');
            n++;
        }
    }
    Log("Total:" @ n, 'Channels');
}

defaultproperties
{
    ExpGainDurationForever=21.0 //this or higher means forever
    HintDuration=5.000000
    HintColor=(R=255,G=128,B=0,A=255)
    bDefaultBindings=True
    bDefaultArtifactBindings=True
    EXPBarColor=(B=128,G=255,R=128,A=255)
    RedColor=(R=255,G=64,B=64,A=255)
    WhiteColor=(B=255,G=255,R=255,A=255)
    WhiteTrans=(B=255,G=255,R=255,A=128)
    //Team colors (taken from HudOLTeamDeathmatch)
    HUDColorTeam(0)=(R=200,G=0,B=0,A=255)
    HUDColorTeam(1)=(R=50,G=64,B=200,A=255)
    HUDColorTeam(2)=(R=0,G=200,B=0,A=255)
    HUDColorTeam(3)=(R=200,G=200,B=0,A=255)
    //StatusIcon stuff
    StatusIconBorderMaterial=Texture'HudContent.Generic.HUD'
    StatusIconBorderMaterialRect=(X=119,Y=257,W=55,H=55)
    StatusIconSize=(X=29,Y=29)
    StatusIconInnerScale=0.75
    StatusIconOverlay=(R=255,G=255,B=255,A=128)
    //
    DisabledOverlay=(R=0,G=0,B=0,A=150)
    LevelText="Level:"
    bVisible=True
    bRequiresTick=True
    VehicleLockSound=Sound'ONSVehicleSounds-S.Hydraulics.Hydraulic03'
    VehicleUnlockSound=Sound'ONSVehicleSounds-S.Hydraulics.Hydraulic04'
    VehicleLockedMessage="Vehicle locked!"
    VehicleUnlockedMessage="Vehicle unlocked!"
    ArtifactTutorialText="You have collected a magic artifact!|Press $1 to use it or press $2 and $3 to browse|if you have multiple artifacts."
    ArtifactMoreOptionsText="See more options..."
    ArtifactNAText="N/A"
    ArtifactBorderMaterial=Texture'HudContent.Generic.HUD'
    ArtifactBorderSize=48
    ArtifactBorderMaterialRect=(X=0,Y=39,W=95,H=54)
    ArtifactIconInnerScale=0.67
    ArtifactHighlightIndention=0.15
    ArtifactRadialSize=250
    SelectedRadialSlot=-1
    //
    SAOFontArrayNames(0)="FontSAO37"
    SAOFontArrayNames(1)="FontSAO29"
    SAOFontArrayNames(2)="FontSAO24"
    SAOFontArrayNames(3)="FontSAO21"
    SAOFontArrayNames(4)="FontSAO17"
    SAOFontArrayNames(5)="FontSAO14"
    SAOFontArrayNames(6)="FontSAO12"
    SAOFontArrayNames(7)="FontSAO11"
    SAOFontArrayNames(8)="FontSAO9"
    SAOFontScreenWidthMedium(0)=2048
    SAOFontScreenWidthMedium(1)=1600
    SAOFontScreenWidthMedium(2)=1280
    SAOFontScreenWidthMedium(3)=1024
    SAOFontScreenWidthMedium(4)=800
    SAOFontScreenWidthMedium(5)=640
    SAOFontScreenWidthMedium(6)=512
    SAOFontScreenWidthMedium(7)=400
    SAOFontScreenWidthMedium(8)=320
}
