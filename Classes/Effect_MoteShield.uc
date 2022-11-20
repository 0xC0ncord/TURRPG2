//=============================================================================
// Effect_MoteShield.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_MoteShield extends Effect_Mote;

var int ShieldRegenPerLevel;

state Activated
{
    function Timer()
    {
        Super.Timer();

        if(Instigator.GetShieldStrength() >= Instigator.GetShieldStrengthMax())
            return;

        Instigator.AddShieldStrength(
            Min(
                Instigator.GetShieldStrengthMax() - Instigator.GetShieldStrength(),
                ShieldRegenPerLevel * Modifier
            )
        );
    }
}

defaultproperties
{
    ShieldRegenPerLevel=5
    EffectClass=class'FX_MoteActive_Gold'
    DoubleEffectClass=class'FX_MoteActive_Gold_Double'
    TripleEffectClass=class'FX_MoteActive_Gold_Triple'
    StatusIconClass=class'StatusIcon_MoteShield'
    DoubleStatusIconClass=class'StatusIcon_MoteShield_Double'
    TripleStatusIconClass=class'StatusIcon_MoteShield_Triple'
    EffectMessageClass=class'EffectMessage_ShieldBoost'
}
