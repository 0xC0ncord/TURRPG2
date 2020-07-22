//=============================================================================
// EffectMessage_Knockback.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Knockback extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="Knockback!"
    EffectMessageSelfString="Knockback by yourself!"
    EffectMessageCauserString="Knockback by $1!"

    DrawColor=(B=0,G=0)
}
