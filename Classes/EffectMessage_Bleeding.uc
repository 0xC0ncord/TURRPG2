//=============================================================================
// EffectMessage_Bleeding.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Bleeding extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You are bleeding!"
    EffectMessageCauserString="Bleeding by $1!"
    EffectMessageSelfString="Bleeding by yourself!"
    DrawColor=(R=255,G=0,B=0)
}
