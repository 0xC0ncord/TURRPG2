//=============================================================================
// EffectMessage_Poison.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Poison extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You are poisoned!"
    EffectMessageSelfString="You poisoned yourself!"
    EffectMessageCauserString="You are poisoned by $1!"

    DrawColor=(B=0,R=0)
}
