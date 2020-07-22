//=============================================================================
// EffectMessage_Repulsion.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Repulsion extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="Repulsion!"
    EffectMessageSelfString="Repulsion by yourself!"
    EffectMessageCauserString="Repulsion by $1!"

    DrawColor=(B=0,G=0)
}
