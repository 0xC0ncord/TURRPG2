//=============================================================================
// EffectMessage_Blindness.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Blindness extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You are blind!"
    EffectMessageCauserString="Blindness by $1!"
    EffectMessageSelfString="Blindness by yourself!"
    DrawColor=(R=255,G=64,B=255)
}
