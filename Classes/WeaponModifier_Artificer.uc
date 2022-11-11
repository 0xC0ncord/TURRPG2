//=============================================================================
// WeaponModifier_Artificer.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Artificer extends RPGWeaponModifier
    DependsOn(RPGCharSettings);

var localized string PatternPoorQuality;
var localized string PatternLowQuality;
var localized string PatternMediumQuality;
var localized string PatternHighQuality;
var localized string PatternPristineQuality;

var ArtificerAugmentBase AugmentList, AugmentListTail;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientInitAugment, ClientRemoveAugment, ClientUpdateDescription;
}

function InitAugments(array<RPGCharSettings.ArtificerAugmentStruct> NewAugments)
{
    local ArtificerAugmentBase Augment;
    local int i;

    SetActive(false);

    //FIXME if an augment ever has any functionality which involves a cooldown,
    //this will need to be rewritten later so that we don't also reset its cooldown
    //in order to avoid an unsealing/sealing exploit
    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        ClientRemoveAugment(Augment);

    for(i = 0; i < NewAugments.Length; i++)
        ClientInitAugment(NewAugments[i].AugmentClass, NewAugments[i].ModifierLevel);

    SetOverlay();
    ClientUpdateDescription();

    SetActive(true);
}

simulated function Destroyed()
{
    local ArtificerAugmentBase Augment, NextAugment;

    Super.Destroyed();

    Augment = AugmentList;
    while(Augment != None)
    {
        NextAugment = Augment.NextAugment;

        if(Role == ROLE_Authority)
            Augment.StopEffect();
        else
            Augment.ClientStopEffect();
        Augment.Free();

        Augment = NextAugment;
    }
}

simulated function ClientInitAugment(class<ArtificerAugmentBase> AugmentClass, int NewLevel)
{
    local ArtificerAugmentBase Augment;

    Augment = ArtificerAugmentBase(Level.ObjectPool.AllocateObject(AugmentClass));

    if(AugmentList == None)
        AugmentList = Augment;
    else
    {
        Augment.PrevAugment = AugmentListTail;
        AugmentListTail.NextAugment = Augment;
    }
    AugmentListTail = Augment;

    Augment.Init(Self, NewLevel);
}

simulated function ClientRemoveAugment(ArtificerAugmentBase Augment)
{
    Augment.Remove();
}

function StartEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.StartEffect();
}

function StopEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.StopEffect();
}

simulated function ClientStartEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.ClientStartEffect();
}

simulated function ClientStopEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.ClientStopEffect();
}

function RPGTick(float dt)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.RPGTick(dt);
}

simulated function ClientRPGTick(float dt)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.ClientRPGTick(dt);
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.AdjustPlayerDamage(Damage, OriginalDamage, InstigatedBy, HitLocation, Momentum, DamageType);
}

function bool PreventDeath(Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(Augment.PreventDeath(Killer, DamageType, HitLocation, bAlreadyPrevented))
            bAlreadyPrevented = true;

    if(bAlreadyPrevented && DamageType != class'Suicided' && Killer != Instigator.Controller)
        return true;
}

function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier)
{
    local ArtificerAugmentBase Augment;
    local bool bAlreadyDenied;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.AllowEffect(EffectClass, Causer, Duration, Modifier))
            bAlreadyDenied = true;

    return !bAlreadyDenied;
}

function SetOverlay(optional Material Mat)
{
    local ArtificerAugmentBase Augment;
    local int MaxLevel;

    if(Mat != None)
    {
        Super.SetOverlay(Mat);
        return;
    }

    // determine which overlay to show, then show it
    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
    {
        if(MaxLevel < Augment.ModifierLevel)
        {
            MaxLevel = Augment.ModifierLevel;
            Mat = Augment.ModifierOverlay;
        }
    }
    Super.SetOverlay(Mat);
}

simulated function ClientUpdateDescription()
{
    BuildDescription();
}

simulated function BuildDescription()
{
    local ArtificerAugmentBase Augment;

    if(AugmentList == None)
    {
        Description = default.Description;
        return;
    }

    Description = AugmentList.GetDescription();

    for(Augment = AugmentList.NextAugment; Augment != None; Augment = Augment.NextAugment)
        Description $= "," @ Augment.GetDescription();
}

simulated static function string StaticGetDescription(int Modifier)
{
    return default.Description;
}

static function string ConstructItemName(class<Weapon> WeaponClass, int Modifier)
{
    local string NewItemName;
    local string Pattern;

    if(default.PatternNeg == "")
        default.PatternNeg = default.PatternPos;

    if(Modifier >= 0)
    {
        if(Modifier > 10)
            Pattern = default.PatternPos;
        else
        {
            switch(Modifier)
            {
                case 0:
                case 1:
                case 2:
                    Pattern = default.PatternPoorQuality;
                    break;
                case 3:
                case 4:
                    Pattern = default.PatternLowQuality;
                    break;
                case 5:
                case 6:
                    Pattern = default.PatternMediumQuality;
                    break;
                case 7:
                case 8:
                    Pattern = default.PatternHighQuality;
                    break;
                case 9:
                case 10:
                    Pattern = default.PatternPristineQuality;
                    break;
            }
        }
    }
    else if(Modifier < 0)
    {
        Pattern = default.PatternNeg;
    }

    NewItemName = Repl(Pattern, "$W", WeaponClass.default.ItemName);

    if(!default.bOmitModifierInName)
    {
        if(Modifier > 0)
            NewItemName @= "+" $ Modifier;
        else if(Modifier < 0)
            NewItemName @= Modifier;
    }

    return NewItemName;
}

defaultproperties
{
    bCanHaveZeroModifier=False
    PatternPoorQuality="Crude Artificer's $W"
    PatternLowQuality="Artificer's Lesser $W"
    PatternMediumQuality="Artificer's $W of Handicraft"
    PatternHighQuality="Artificer's Pristine $W"
    PatternPristineQuality="Artificer's Mastercrafted $W"
    Description="embodies effects which are sealed by an Artificer's Charm"
    PatternPos="Artificer's $W"
    PatternNeg="Artificer's $W"
}
