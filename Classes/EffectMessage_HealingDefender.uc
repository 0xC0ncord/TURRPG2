//=============================================================================
// EffectMessage_HealingDefender.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EffectMessage_HealingDefender extends RPGEffectMessage;


static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, //victim
    optional PlayerReplicationInfo RelatedPRI_2, //causer
    optional Object OptionalObject
)
{
    if(RelatedPRI_2 != None)
    {
        if(RelatedPRI_2 == RelatedPRI_1)
        {
            return Repl(
                default.EffectMessageSelfString,
                "$2",
                class'Util'.static.FormatPercent(float(Switch) * 0.05));
        }
        else
        {
            return Repl(
                Repl(
                    default.EffectMessageCauserString,
                    "$1",
                    RelatedPRI_2.PlayerName),
                "$2",
                class'Util'.static.FormatPercent(float(Switch) * 0.05));
        }
    }
    else
    {
        return Repl(
            default.EffectMessageString,
            "$2",
            class'Util'.static.FormatPercent(float(Switch) * 0.05));
    }
}

defaultproperties
{
    EffectMessageString="You have +$2 damage reduction!"
    EffectMessageSelfString="You have +$2 damage reduction!"
    EffectMessageCauserString="$1 gives you +$2 damage reduction!"

    DrawColor=(G=0,R=0)
    PosY=0.8
}
