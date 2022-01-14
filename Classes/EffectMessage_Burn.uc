//=============================================================================
// EffectMessage_Burn.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Burn extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You are burning!"
    EffectMessageCauserString="$1 has inflicted a burn on you!"
    EffectMessageSelfString="You are burning!"
    DrawColor=(B=0,G=32)
}
