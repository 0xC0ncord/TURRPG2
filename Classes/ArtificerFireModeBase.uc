//=============================================================================
// ArtificerFireModeBase.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerFireModeBase extends Object;

struct IconLocationStruct
{
    var() float X, Y;
    var() float Width, Height;
};

var() Material IconMaterial;
var() IconLocationStruct IconLocation;
var() class<WeaponFire> FireModeClass;

var ArtificerFireModeBase NextFireMode;
var WeaponFire FireMode;
var WeaponModifier_Artificer WeaponModifier;
var Weapon Weapon;
var byte ModeNum;
var bool bEnabled;
var bool bShowChargingBar;
var int ModifierLevel;
var float OldSeekCheckTime;

function WeaponFire CreateFireMode()
{
    local WeaponFire NewFireMode;

    NewFireMode = new(None) FireModeClass;
    NewFireMode.ThisModeNum = ModeNum;
    NewFireMode.Weapon = WeaponModifier.Weapon;
    NewFireMode.Instigator = WeaponModifier.Weapon.Instigator;
    NewFireMode.Level = WeaponModifier.Level;
    NewFireMode.Owner = WeaponModifier.Weapon;
    NewFireMode.PreBeginPlay();
    NewFireMode.BeginPlay();
    NewFireMode.PostBeginPlay();
    NewFireMode.SetInitialState();
    NewFireMode.PostNetBeginPlay();
    NewFireMode.PostNetBeginPlay();
    return NewFireMode;
}

function ReInitFireMode()
{
    if(FireMode == None)
        return;

    FireMode.Instigator = WeaponModifier.Instigator;
    FireMode.ThisModeNum = ModeNum;
    FireMode.Owner = WeaponModifier.Owner;
    FireMode.Weapon = WeaponModifier.Weapon;
    FireMode.Level = WeaponModifier.Level;
}

function Initialize()
{
    FireMode = CreateFireMode();
    if(FireMode != None)
        bEnabled = true;
}

function Deinitialize()
{
    if(FireMode != None)
    {
        FireMode.DestroyEffects();
        FireMode.FlashEmitter = None;
        FireMode.SmokeEmitter = None;
        FireMode.Owner = None;
        FireMode.Weapon = None;

        FireMode = None;
    }
}

function SetLevel(int NewModifierLevel)
{
    ModifierLevel = NewModifierLevel;
}

function Activate();
function Deactivate();

function ModeTick(float dt);

function DrawIcon(Canvas Canvas, float PosX, float PosY)
{
    local float ScaleX, ScaleY;

    ScaleX = Canvas.ClipX / 1280f;
    ScaleY = Canvas.ClipY / 1024f;
    Canvas.SetPos(PosX + (ScaleX * (24.5 - (IconLocation.Width * 0.5))), PosY + (ScaleY * (23.5 - (IconLocation.Height * 0.5))));
    Canvas.DrawTile(IconMaterial, IconLocation.Width * ScaleX, IconLocation.Height * ScaleY, IconLocation.X, IconLocation.Y, IconLocation.Width, IconLocation.Height);
}

function RenderOverlays(Canvas Canvas);

function Free()
{
    Deinitialize();
    NextFireMode = None;
    WeaponModifier = None;
    Weapon = None;
}

defaultproperties
{
    ModifierLevel=1
}
