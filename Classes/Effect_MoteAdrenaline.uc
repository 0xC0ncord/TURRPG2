//=============================================================================
// Effect_MoteAdrenaline.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_MoteAdrenaline extends Effect_Mote;

var int AdrenalineRegenPerLevel;

state Activated
{
    function Timer()
    {
        Super.Timer();

        if(!Instigator.InCurrentCombo() &&
            !class'RPGArtifact'.static.HasActiveArtifact(Instigator))
        {
            InstigatorRPRI.Controller.AwardAdrenaline(AdrenalineRegenPerLevel * Modifier);
        }
    }
}

defaultproperties
{
    AdrenalineRegenPerLevel=5
    EffectClass=class'FX_MoteActive_Orange'
    DoubleEffectClass=class'FX_MoteActive_Orange_Double'
    TripleEffectClass=class'FX_MoteActive_Orange_Triple'
    StatusIconClass=class'StatusIcon_MoteAdrenaline'
    DoubleStatusIconClass=class'StatusIcon_MoteAdrenaline_Double'
    TripleStatusIconClass=class'StatusIcon_MoteAdrenaline_Triple'
    EffectMessageClass=class'EffectMessage_Adrenaline'
}
