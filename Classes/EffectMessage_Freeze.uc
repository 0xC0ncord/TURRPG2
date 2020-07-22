//=============================================================================
// EffectMessage_Freeze.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Freeze extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You are frozen!"
    EffectMessageSelfString="You froze yourself!"
    EffectMessageCauserString="You are frozen by $1!"

    DrawColor=(B=128,G=128,R=128)
}
