//=============================================================================
// Effect_Repulsion.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Repulsion extends Effect_Knockback;

defaultproperties
{
    bAllowOnSelf=False
    bAllowOnVehicles=False

    DamageType=class'DamTypeRepulsion'

    EffectSound=None
    EffectOverlay=Shader'TURRPG2.Overlays.PulseRedShader'
    EffectMessageClass=class'EffectMessage_Repulsion'
}
