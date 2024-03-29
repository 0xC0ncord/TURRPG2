//=============================================================================
// WeaponModifier_Poison.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Poison extends RPGWeaponModifier;

var RPGRules RPGRules;

var localized string PoisonText, PoisonAbsText;

var config int PoisonLifespan;
var config int PoisonMode; //0 = PM_Absolute, 1 = PM_Percentage, 2 = PM_Curve

var config float BasePercentage;
var config float Curve;

var config int AbsDrainPerLevel;
var config float PercDrainPerLevel;

var config int MinHealth; //cannot drain below this

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local Effect_Poison Poison;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    Identify();

    Poison = Effect_Poison(class'Effect_Poison'.static.Create(Injured, InstigatedBy.Controller, PoisonLifespan, Modifier));
    if(Poison != None)
    {
        Poison.PoisonMode = EPoisonMode(PoisonMode);
        Poison.BasePercentage = BasePercentage;
        Poison.Curve = Curve;
        Poison.AbsDrainPerLevel = AbsDrainPerLevel;
        Poison.PercDrainPerLevel = PercDrainPerLevel;
        Poison.MinHealth = MinHealth;
        Poison.Start();
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(PoisonText);

    if(EPoisonMode(PoisonMode) == PM_Absolute) {
        AddToDescription(Repl(PoisonAbsText, "$1", Modifier * AbsDrainPerLevel));
    }
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.PoisonText);
    if(EPoisonMode(default.PoisonMode) == PM_Absolute)
        StaticAddToDescription(Description, Modifier, Repl(default.PoisonAbsText, "$1", Modifier * default.AbsDrainPerLevel));

    return Description;
}

defaultproperties
{
    PoisonText="poisons targets"
    PoisonAbsText="$1 health/s"
    PoisonLifespan=5
    MinModifier=1
    MaxModifier=5
    ModifierOverlay=Shader'PoisonShader'
    PatternPos="Poisonous $W"
    PoisonMode=PM_Curve

    BasePercentage=0.05
    Curve=1.25
    AbsDrainPerLevel=2
    PercDrainPerLevel=0.10
    MinHealth=10
    //AI
    AIRatingBonus=0.075
}
