//=============================================================================
// ArtificerAugmentBase.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugmentBase extends Object;

var() float BonusPerLevel;
var() int MaxLevel;
var() string ModifierName;
var() localized string Description;
var() Material IconMaterial;
var() Color ModifierColor;
var() Material ModifierOverlay;

var int ModifierLevel;

var Weapon Weapon;
var WeaponModifier_Artificer WeaponModifier;
var Pawn Instigator;
var ObjectPool ObjectPool;

var ArtificerAugmentBase NextAugment, PrevAugment;

static function bool CanApply(WeaponModifier_Artificer WM)
{
    local ArtificerAugmentBase Augment;

    if(default.MaxLevel == 0)
        return true;

    Augment = GetFor(WM);
    return (Augment == None || Augment.ModifierLevel < default.MaxLevel);
}

static final function ArtificerAugmentBase GetFor(WeaponModifier_Artificer WM)
{
    local ArtificerAugmentBase Augment;

    for(Augment = WM.AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(Augment == default.Class)
            return Augment;

    return None;
}

function Init(WeaponModifier_Artificer WM, int NewModifierLevel)
{
    EPRINTD(PlayerController(WM.Instigator.Controller), "New, Level" @ NewModifierLevel);

    WeaponModifier = WM;
    ModifierLevel = NewModifierLevel;
    Weapon = WM.Weapon;
    Instigator = Weapon.Instigator;
    ObjectPool = WM.Level.ObjectPool;
}

final function Remove()
{
    if(WeaponModifier.Role == ROLE_Authority)
        StopEffect();
    else
        ClientStopEffect();

    if(WeaponModifier.AugmentListTail == Self)
    {
        WeaponModifier.AugmentListTail = PrevAugment;
    }
    else
    {
        if(PrevAugment != None)
            PrevAugment.NextAugment = NextAugment;
        if(NextAugment != None)
            NextAugment.PrevAugment = PrevAugment;
    }

    if(WeaponModifier.AugmentList == Self)
    {
        WeaponModifier.AugmentList = None;
    }

    Free();
}

function Free()
{
    WeaponModifier = None;
    Weapon = None;
    Instigator = None;
    NextAugment = None;
    PrevAugment = None;
    ObjectPool.FreeObject(Self);
    ObjectPool = None;
}

function StartEffect(); //weapon gets drawn
function StopEffect(); //weapon gets put down

function ClientStartEffect();
function ClientStopEffect();

function RPGTick(float dt); //called only if weapon is active
function ClientRPGTick(float dt);

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType);

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType);

function bool PreventDeath(Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented)
{
    return false;
}

function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier)
{
    return true;
}

function string GetDescription()
{
    return Repl(default.Description, "$1", class'Util'.static.FormatPercent(BonusPerLevel * Max(1, ModifierLevel)));
}

static function string StaticGetDescription(optional int ModifierLevel)
{
    return Repl(default.Description, "$1", class'Util'.static.FormatPercent(default.BonusPerLevel * Max(1, ModifierLevel)));
}

defaultproperties
{
    ModifierName="Modifier"
    Description="$1 damage"
    ModifierColor=(R=255,G=255,B=255)
}
