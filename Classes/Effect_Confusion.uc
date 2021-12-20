//=============================================================================
// Effect_Confusion.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Confusion extends RPGEffect;

state Activated
{
    function BeginState()
    {
        Super.BeginState();
        if(MonsterController(Instigator.Controller) != None)
            MonsterController(Instigator.Controller).ChangeEnemy(Instigator, true);
    }

    function EndState()
    {
        if(Monster(Instigator) != None && MonsterController(Instigator.Controller) != None)
        {
            MonsterController(Instigator.Controller).Enemy = None;
            MonsterController(Instigator.Controller).FindNewEnemy();
        }
        Super.EndState();
    }
}

defaultproperties
{
     EffectClass=Class'FX_Confusion'
     EffectMessageClass=Class'EffectMessage_Confusion'
     StatusIconClass=Class'StatusIcon_Confusion'
}
