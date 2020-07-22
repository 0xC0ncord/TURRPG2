//=============================================================================
// RPGDevoidEffect.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
    Effects that aren't really doing anything.
    They still provide a central place to ask whether certain things can be done to a target (e.g. Ultima immunity).
*/
class RPGDevoidEffect extends RPGEffect abstract;

static function RPGEffect Create(Pawn Other, optional Controller Causer, optional float OverrideDuration, optional float NewModifier)
{
    Warn("Tried to instantiate devoid effect class" @ default.class $ "!");
    return None;
}

defaultproperties
{
    Duration=0
}
