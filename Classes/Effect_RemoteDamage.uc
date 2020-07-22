//=============================================================================
// Effect_RemoteDamage.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_RemoteDamage extends RPGEffect;

var float EstimatedUDamageTime;
var float ExpPerDamage;

function bool ShouldDisplayEffect()
{
    return true;
}

state Activated
{
    function BeginState()
    {
        Super.BeginState();
        Instigator.EnableUDamage(EstimatedUDamageTime);
    }

    function EndState()
    {
        Super.EndState();
        Instigator.DisableUDamage();
    }
}

function Destroyed()
{
    Super.Destroyed();
    Instigator.DisableUDamage();

    //Fix the annoying UDamage running out sounds
    if(xPawn(Instigator) != None && xPawn(Instigator).UDamageTimer != None)
        xPawn(Instigator).UDamageTimer.Destroy();
}

defaultproperties
{
    EstimatedUDamageTime=20
    EffectMessageClass=Class'EffectMessage_UDamage'
    bHarmful=False
    bAllowOnTeammates=True
}
