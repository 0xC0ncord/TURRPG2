//=============================================================================
// WeaponModifier_AntiAir.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_AntiAir extends RPGWeaponModifier;

var localized string AntiAirText;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if(Injured != InstigatedBy && Injured.Physics == PHYS_Flying)
    {
        if(!bIdentified)
            Identify();
        Damage += float(OriginalDamage) * BonusPerLevel * Modifier;
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(AntiAirText, BonusPerLevel);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.AntiAirText, default.BonusPerLevel);

    return Description;
}

defaultproperties
{
    BonusPerLevel=0.020000
    DamageBonus=0.010000
    AntiAirText="$1 damage against flying enemies"
    MinModifier=1
    MaxModifier=4
    bCanHaveZeroModifier=False
    ModifierOverlay=Shader'AntiAirShader'
    PatternPos="Anti-Air $W"
    //AI
    AIRatingBonus=0.0125
}
