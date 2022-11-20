//=============================================================================
// Effect_MoteDamageReduction.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_MoteDamageReduction extends Effect_Mote;

var int DamageReductionPerLevel;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Damage = Max(1, Damage - (Damage * DamageReductionPerLevel * Modifier));
}

defaultproperties
{
    DamageReductionPerLevel=0.05
    EffectClass=class'FX_MoteActive_Violet'
    DoubleEffectClass=class'FX_MoteActive_Violet_Double'
    TripleEffectClass=class'FX_MoteActive_Violet_Triple'
    StatusIconClass=class'StatusIcon_MoteDamageReduction'
    DoubleStatusIconClass=class'StatusIcon_MoteDamageReduction_Double'
    TripleStatusIconClass=class'StatusIcon_MoteDamageReduction_Triple'
    EffectMessageClass=class'EffectMessage_DamageReduction'
}
