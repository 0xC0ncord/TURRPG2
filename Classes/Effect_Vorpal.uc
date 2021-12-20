//=============================================================================
// Effect_Vorpal.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Vorpal extends RPGInstantEffect;

function DoEffect()
{
    Instigator.Died(EffectCauser, class'DamTypeVorpal', Instigator.Location);
}

defaultproperties
{
    EffectSound=Sound'WeaponSounds.Misc.instagib_rifleshot'
    EffectClass=class'FX_VorpalExplosion'
    EffectMessageClass=class'EffectMessage_Vorpal'
}
