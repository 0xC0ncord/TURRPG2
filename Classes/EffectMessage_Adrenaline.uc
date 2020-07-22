//=============================================================================
// EffectMessage_Adrenaline.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//This message is sent to players who have some adrenaline given to them
class EffectMessage_Adrenaline extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="Adrenaline!"
    EffectMessageCauserString="$1 has given you extra adrenaline!"
    EffectMessageSelfString="You've given yourself extra adrenaline!"
    DrawColor=(G=192,B=0)
}
