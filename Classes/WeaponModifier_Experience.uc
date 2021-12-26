//=============================================================================
// WeaponModifier_Experience.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Experience extends RPGWeaponModifier;

var localized string ExperienceText;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if(Injured == Instigator || class'Util'.static.SameTeamP(Injured, Instigator))
        return;

    if(!bIdentified)
        Identify();

    if(RPRI != None)
        RPRI.AwardExperience(FMin(0.01, float(Damage) * (BonusPerLevel * Modifier)));
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(ExperienceText, BonusPerLevel);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.ExperienceText, default.BonusPerLevel);

    return Description;
}

defaultproperties
{
    BonusPerLevel=0.010000
    DamageBonus=0.010000
    ExperienceText="$1 experience gain"
    MinModifier=1
    MaxModifier=5
    bCanHaveZeroModifier=False
    ModifierOverlay=Shader'ExperienceShader'
    PatternPos="$W of Experience"
    //AI
    AIRatingBonus=0.01
}
