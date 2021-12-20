//=============================================================================
// EffectMessage_Mundane.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Mundane extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You feel dull!"
    EffectMessageCauserString="Mundane by $1!"
    EffectMessageSelfString="Mundane by yourself!"
    DrawColor=(R=255,G=64,B=192)
}
