//=============================================================================
// EffectMessage_PullForward.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_PullForward extends RPGEffectMessage;

defaultproperties
{
    EffectMessageString="Pulled forward!"
    EffectMessageSelfString="Pull-forward by yourself!"
    EffectMessageCauserString="Pulled forward by $1!"

    DrawColor=(R=224,G=224,B=255)
}
