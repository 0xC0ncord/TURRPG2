//=============================================================================
// WeaponModifier_Speed.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Speed extends RPGWeaponModifier;

var float SpeedModifier;

var localized string SpeedText;

function StartEffect()
{
    SpeedModifier = 1.0f + BonusPerLevel * Abs(float(Modifier));
    if(Modifier < 0 && SpeedModifier != 0)
        SpeedModifier = 1.0 / SpeedModifier;

    class'Util'.static.PawnScaleSpeed(Instigator, SpeedModifier);

    Identify();
}

function StopEffect()
{
    if(SpeedModifier != 0)
        class'Util'.static.PawnScaleSpeed(Instigator, 1.0f / SpeedModifier);

    SpeedModifier = 0;
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(SpeedText, BonusPerLevel);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.SpeedText, default.BonusPerLevel);

    return Description;
}

defaultproperties
{
    SpeedText="$1 movement speed"
    DamageBonus=0.050000
    BonusPerLevel=0.030000
    MinModifier=-3
    MaxModifier=7
    bCanHaveZeroModifier=False
    ModifierOverlay=Shader'XGameShaders.BRShaders.BombIconBS'
    PatternPos="$W of Speed"
    PatternNeg="$W of Slowness"
    //AI
    AIRatingBonus=0.025
}
