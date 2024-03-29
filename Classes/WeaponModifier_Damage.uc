//=============================================================================
// WeaponModifier_Damage.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Damage extends RPGWeaponModifier;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
    Identify();
}

defaultproperties
{
    DamageBonus=0.10
    MinModifier=-3
    MaxModifier=6
    bCanHaveZeroModifier=False
    ModifierOverlay=Combiner'DamageShader'
    PatternPos="$W of Damage"
    PatternNeg="$W of Reduced Damage"
}
