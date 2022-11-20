//=============================================================================
// Effect_MoteHealth.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_MoteHealth extends Effect_Mote;

var int HealthRegenPerLevel;

state Activated
{
    function Timer()
    {
        Super.Timer();

        Instigator.GiveHealth(HealthRegenPerLevel * Modifier, Instigator.HealthMax);
    }
}

defaultproperties
{
    HealthRegenPerLevel=5
    EffectClass=class'FX_MoteActive_Blue'
    DoubleEffectClass=class'FX_MoteActive_Blue_Double'
    TripleEffectClass=class'FX_MoteActive_Blue_Triple'
    StatusIconClass=class'StatusIcon_MoteHealth'
    DoubleStatusIconClass=class'StatusIcon_MoteHealth_Double'
    TripleStatusIconClass=class'StatusIcon_MoteHealth_Triple'
    EffectMessageClass=class'EffectMessage_Heal'
}
