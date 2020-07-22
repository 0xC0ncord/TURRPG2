//=============================================================================
// EffectMessage_Heal.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Heal extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="Healed!"
    EffectMessageSelfString="You healed yourself!"
    EffectMessageCauserString="$1 has healed you!"

    DrawColor=(G=0,R=0)
}
