//=============================================================================
// Effect_BrokenArmor.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_BrokenArmor extends RPGEffect;

var float BaseDamageMult;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    //Randomly multiply damage
    Damage += float(OriginalDamage) * (BaseDamageMult + Rand(Modifier) * 0.01);
}

defaultproperties
{
    BaseDamageMult=0.04
    Duration=3.00
    bAllowOnSelf=False
    bAllowOnTeammates=False
    EffectSound=Sound'GeneralImpacts.Wet.Breakbone_04'
    EffectClass=class'FX_BrokenArmor'
    EffectMessageClass=class'EffectMessage_BrokenArmor'
    StatusIconClass=class'StatusIcon_BrokenArmor'
}
