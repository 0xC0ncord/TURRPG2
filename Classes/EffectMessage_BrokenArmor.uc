//=============================================================================
// EffectMessage_BrokenArmor.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_BrokenArmor extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="You feel defenseless!"
    EffectMessageCauserString="Broken Armor by $1!"
    EffectMessageSelfString="Broken Armor by yourself!"
    DrawColor=(R=255,G=64,B=32)
}
