//=============================================================================
// EffectMessage_Weakness.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Weakness extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You feel weak!"
    EffectMessageCauserString="Weakness by $1!"
    EffectMessageSelfString="Weakness by yourself!"
    DrawColor=(R=255,G=128,B=192)
}
