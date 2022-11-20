//=============================================================================
// Effect_PullForward.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_PullForward extends Effect_Knockback;

defaultproperties
{
    EffectOverlay=Shader'TURRPG2.Overlays.PulseRedShader'
    EffectMessageClass=class'EffectMessage_PullForward'
}
