//=============================================================================
// WeaponModifier_Feather.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Feather extends RPGWeaponModifier;

var float JumpZModifier, MaxFallSpeedModifier;

var config float MaxFallSpeedBonus;

var localized string FeatherText, FallDamageText;

function StartEffect()
{
    Identify();

    JumpZModifier = 1.f + BonusPerLevel * Abs(float(Modifier));
    if(Modifier < 0 && JumpZModifier != 0)
        JumpZModifier = 1.0 / JumpZModifier;

    MaxFallSpeedModifier = 1.f + MaxFallSpeedBonus * Abs(float(Modifier));
    if(Modifier < 0 && MaxFallSpeedModifier != 0)
        MaxFallSpeedModifier = 1.0 / MaxFallSpeedModifier;

    Instigator.JumpZ *= JumpZModifier;
    Instigator.MaxFallSpeed *= MaxFallSpeedModifier;
}

function StopEffect()
{
    if(JumpZModifier != 0)
        Instigator.JumpZ /= JumpZModifier;

    if(MaxFallSpeedModifier != 0)
        Instigator.MaxFallSpeed /= MaxFallSpeedModifier;

    JumpZModifier = 0;
    MaxFallSpeedModifier = 0;
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(FeatherText, BonusPerLevel);
    AddToDescription(FallDamageText, MaxFallSpeedBonus);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    StaticAddToDescription(Description, Modifier, default.FeatherText, default.BonusPerLevel);
    StaticAddToDescription(Description, Modifier, default.FallDamageText, default.MaxFallSpeedBonus);

    return Description;
}

defaultproperties
{
    FeatherText="$1 jump height"
    FallDamageText="$1 soft landing"
    DamageBonus=0.040000
    BonusPerLevel=0.050000
    MaxFallSpeedBonus=0.030000
    MinModifier=-3
    MaxModifier=10
    bCanHaveZeroModifier=False
    ModifierOverlay=Shader'FeatherShader'
    PatternPos="$W of Feather"
    PatternNeg="$W of Burden"
    //AI
    AIRatingBonus=0.000000
}
