//=============================================================================
// EffectMessage_ShieldBoost.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//This message is sent to players who have their shields boosted
class EffectMessage_ShieldBoost extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="Shield Boost!"
    EffectMessageCauserString="$1 has boosted your shields!"
    EffectMessageSelfString="You've boosted your shields!"
    DrawColor=(B=0)
}
