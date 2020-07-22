//=============================================================================
// RPGInstantEffect.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
    Optimized for effects without a duration
*/
class RPGInstantEffect extends RPGEffect abstract;

function DoEffect();

state Activated
{
    function BeginState()
    {
        Super.BeginState();

        DoEffect();
    }

    function Timer()
    {
        Destroy();
    }
}

defaultproperties
{
    TimerInterval=0 //display message only one
}
