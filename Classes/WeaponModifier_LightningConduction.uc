//=============================================================================
// WeaponModifier_LightningConduction.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_LightningConduction extends RPGWeaponModifier;

var localized string LCText;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Damage > 0 &&
        (DamageType == class'DamTypeSniperShot' ||
        DamageType == class'DamTypeSniperHeadShot' ||
        DamageType == class'DamTypeLightningRod')
    )
    {
        Identify();
        Damage = Max(0, Damage - float(OriginalDamage) * (1 - BonusPerLevel * Modifier));
    }

    Super.AdjustPlayerDamage(Damage, OriginalDamage, InstigatedBy, HitLocation, Momentum, DamageType);
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(LCText, BonusPerLevel);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    StaticAddToDescription(Description, Modifier, default.LCText, default.BonusPerLevel);

    return Description;
}

defaultproperties
{
    LCText="$1 lightning dmg reduction"
    DamageBonus=0.04
    BonusPerLevel=0.10
    MinModifier=2
    MaxModifier=6
    ModifierOverlay=FinalBlend'AW-Shaders.Shaders.AW-LightskinFinal'
    PatternPos="$W of Lightning Conduction"
    //AI
    AIRatingBonus=0
    CountersDamage(0)=class'DamTypeSniperShot'
    CountersDamage(1)=class'DamTypeSniperHeadShot'
    CountersDamage(2)=class'DamTypeLightningRod'
}
