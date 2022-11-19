//=============================================================================
// EffectMessage_Ammo.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//This message is sent to players who have some ammo given to them
class EffectMessage_Ammo extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="Extra ammo!"
    EffectMessageCauserString="$1 gives you extra ammo!"
    EffectMessageSelfString="You've given yourself extra ammo!"
    DrawColor=(R=32,G=128,B=32)
}
