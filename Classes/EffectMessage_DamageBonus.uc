//=============================================================================
// EffectMessage_DamageBonus.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_DamageBonus extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You now have increased damage!"
    EffectMessageCauserString="$1 has given you increased damage!"
    EffectMessageSelfString="You now have increased damage!"
    DrawColor=(B=0,G=0,R=255)
}

