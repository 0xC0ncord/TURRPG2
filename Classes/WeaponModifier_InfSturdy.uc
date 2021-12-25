//=============================================================================
// WeaponModifier_InfSturdy.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_InfSturdy extends WeaponModifier_Infinity;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Identify();
    Momentum = vect(0, 0, 0);
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(class'WeaponModifier_Sturdy'.default.SturdyText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    StaticAddToDescription(Description, Modifier, class'WeaponModifier_Sturdy'.default.SturdyText);

    return Description;
}

defaultproperties
{
    DamageBonus=0.075
    MinModifier=4
    MaxModifier=10
    ModifierOverlay=Combiner'InfSturdyShader'
    PatternPos="$W of Infinite Sturdiness"
    bCanHaveZeroModifier=True
    //AI
    AIRatingBonus=0.10
    CountersModifier(0)=class'WeaponModifier_Knockback'
    CountersDamage(0)=class'DamTypeCounterShove'
}
