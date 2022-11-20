//=============================================================================
// Effect_MoteDamageBonus.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_MoteDamageBonus extends Effect_Mote;

var float DamageBonusPerLevel;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Victim, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Damage += (Damage * DamageBonusPerLevel * Modifier);
}

defaultproperties
{
    DamageBonusPerLevel=0.05
    EffectClass=class'FX_MoteActive_Red'
    DoubleEffectClass=class'FX_MoteActive_Red_Double'
    TripleEffectClass=class'FX_MoteActive_Red_Triple'
    StatusIconClass=class'StatusIcon_MoteDamageBonus'
    DoubleStatusIconClass=class'StatusIcon_MoteDamageBonus_Double'
    TripleStatusIconClass=class'StatusIcon_MoteDamageBonus_Triple'
    EffectMessageClass=class'EffectMessage_DamageBonus'
}
