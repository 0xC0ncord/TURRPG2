//=============================================================================
// Effect_Weakness.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Weakness extends RPGEffect;

var float DamageDecreaseFactor;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Injured == Instigator && Damage > 0)
        Damage = Damage - (Damage * Modifier * DamageDecreaseFactor);
}

defaultproperties
{
    DamageDecreaseFactor=0.100000
    EffectClass=class'FX_Weakness'
    EffectMessageClass=class'EffectMessage_Weakness'
    EffectOverlay=Shader'MundaneOverlay'
    StatusIconClass=class'StatusIcon_Mundane'
}
