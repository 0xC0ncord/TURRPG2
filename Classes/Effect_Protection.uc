//=============================================================================
// Effect_Protection.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Protection extends RPGEffect;

defaultproperties
{
    bHarmful=False
    bAllowStacking=False

    TimerInterval=0 //no message repeat

    EffectSound=Sound'TURRPG2.Artifacts.Protection'
    EffectMessageClass=class'EffectMessage_Protection'
    StatusIconClass=class'StatusIcon_Protection'
}
