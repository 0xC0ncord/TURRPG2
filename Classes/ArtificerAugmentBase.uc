//=============================================================================
// ArtificerAugmentBase.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugmentBase extends Object
    DependsOn(RPGCharSettings);

var() float BonusPerLevel;
var() int MaxLevel;
var() string ModifierName;
var() localized string Description; //for the weapon modifier description
var() localized string LongDescription; //for the menu
var() Material IconMaterial;
var() Color ModifierColor;
var() Material ModifierOverlay;
var() array<class<ArtificerAugmentBase> > ConflictsWith;

var int ModifierLevel;

var Weapon Weapon;
var WeaponModifier_Artificer WeaponModifier;
var Pawn Instigator;
var ObjectPool ObjectPool;

var ArtificerAugmentBase NextAugment, PrevAugment;

var array<class<ArtificerAugmentBase> > AugmentOrder; //internal order of augments for sorting
var int OrderIndex; //cached index from internal AugmentOrder

var localized string Text_AlreadyAtMax;
var localized string Text_ConflictsWith;

//determine if this augment can be inserted into an array of others and add it, or return false otherwise
static function bool InsertInto(out array<RPGCharSettings.ArtificerAugmentStruct> Augments, optional out string Reason)
{
    local int i, x;

    if(default.MaxLevel > 0 || default.ConflictsWith.Length != 0)
    {
        for(i = 0; i < default.ConflictsWith.Length; i++)
        {
            for(x = 0; x < Augments.Length; x++)
            {
                if(default.ConflictsWith[i] == Augments[x].AugmentClass)
                {
                    Reason = Repl(default.Text_ConflictsWith, "$1", default.ConflictsWith[i].default.ModifierName);
                    return false;
                }
            }
        }

        for(i = 0; i < Augments.Length; i++)
        {
            if(Augments[i].AugmentClass == default.Class)
            {
                if(Augments[i].ModifierLevel >= default.MaxLevel)
                {
                    Reason = default.Text_AlreadyAtMax;
                    return false;
                }
                else
                {
                    Augments[i].ModifierLevel++;
                    return true;
                }
            }
        }
    }

    Augments.Length = i + 1;
    Augments[i].AugmentClass = default.Class;
    Augments[i].ModifierLevel = 1;
    return true;
}

static function bool AllowedOn(Weapon W)
{
    return true;
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
    Weapon = WM.Weapon;
    Instigator = Weapon.Instigator;
    ObjectPool = WM.Level.ObjectPool;
    OrderIndex = class'Util'.static.InArray(Class, default.AugmentOrder);

    SetLevel(NewModifierLevel);
}

function SetLevel(int NewModifierLevel)
{
    ModifierLevel = NewModifierLevel;
}

function Apply();

final function Remove()
{
    EPRINTD(PlayerController(WeaponModifier.Instigator.Controller), "Removing" @ Self);

    if(WeaponModifier.Role == ROLE_Authority)
        StopEffect();
    else
        ClientStopEffect();

    if(WeaponModifier.AugmentList == Self)
        WeaponModifier.AugmentList = NextAugment;
    if(WeaponModifier.AugmentListTail == Self)
        WeaponModifier.AugmentListTail = PrevAugment;

    if(NextAugment != None)
        NextAugment.PrevAugment = PrevAugment;
    if(PrevAugment != None)
        PrevAugment.NextAugment = NextAugment;

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

static function string StaticGetLongDescription(optional int ModifierLevel)
{
    return Repl(default.LongDescription, "$1", class'Util'.static.FormatPercent(default.BonusPerLevel * Max(1, ModifierLevel)));
}

defaultproperties
{
    ModifierName="Modifier"
    Description="$1 damage"
    LongDescription="Increases weapon damage by $1 per level."
    ModifierColor=(R=255,G=255,B=255)
    AugmentOrder(0)=Class'ArtificerAugment_Infinity'
    AugmentOrder(1)=Class'ArtificerAugment_Damage'
    AugmentOrder(2)=Class'ArtificerAugment_Energy'
    AugmentOrder(3)=Class'ArtificerAugment_Knockback'
    AugmentOrder(4)=Class'ArtificerAugment_Flight'
    AugmentOrder(5)=Class'ArtificerAugment_Spread'
    Text_AlreadyAtMax="Augment is at its maximum possible level."
    Text_ConflictsWith="Augment cannot be sealed alongside $1."
}
