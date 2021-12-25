//=============================================================================
// WeaponModifier_Freeze.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Freeze extends RPGWeaponModifier;

var config float FreezeMax, FreezeDuration;

var localized string FreezeText;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local RPGEffect Effect;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if(Damage > 0)
    {
        Effect = class'Effect_Freeze'.static.Create(
            Injured,
            InstigatedBy.Controller,
            Modifier * FreezeDuration,
            1.0f - FMin(BonusPerLevel * Modifier, FreezeMax));

        if(Effect != None)
        {
            Identify();
            Effect.Start();
        }
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(FreezeText, FMin(BonusPerLevel, FreezeMax / float(Modifier)));
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    StaticAddToDescription(Description, Modifier, default.FreezeText, FMin(default.BonusPerLevel, default.FreezeMax / float(Modifier)));

    return Description;
}

defaultproperties
{
    BonusPerLevel=0.15
    FreezeMax=0.90
    FreezeDuration=0.50
    FreezeText="slows targets down $1"
    DamageBonus=0.05
    MinModifier=4
    MaxModifier=6
    ModifierOverlay=Shader'FreezeShader'
    PatternPos="Freezing $W"
    //AI
    AIRatingBonus=0.05
}
