//=============================================================================
// EffectMessage_Confusion.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_Confusion extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You are confused!"
    EffectMessageCauserString="Confusion by $1!"
    EffectMessageSelfString="Confusion by yourself!"
    DrawColor=(R=255,G=255,B=0)
}
