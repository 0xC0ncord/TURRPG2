//=============================================================================
// Effect_Mundane.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Mundane extends RPGEffect;

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    if(Other.Controller == None || !Other.Controller.bAdrenalineEnabled)
        return false;
    return Super.CanBeApplied(Other, Causer, Duration, Modifier);
}

function ModifyAdrenalineGain(out float Amount, float OriginalAmount, optional Object Source)
{
    Amount = 0;
}

defaultproperties
{
    EffectClass=class'FX_Weakness'
    EffectMessageClass=class'EffectMessage_Mundane'
    EffectOverlay=Shader'MundaneOverlay'
    StatusIconClass=class'StatusIcon_Mundane'
}
