//=============================================================================
// Effect_HuntersMark.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_HuntersMark extends RPGEffect;

var float BaseDamageMult;

var FX_HuntersMarkOverlay Mark;
var bool bOldAlwaysRelevant;

state Activated
{
    function BeginState()
    {
        Super.BeginState();

        if(!bRestarting)
        {
            if(!Instigator.bAlwaysRelevant)
                Instigator.bAlwaysRelevant = true;
            else
                bOldAlwaysRelevant = true;

            Mark = Spawn(class'FX_HuntersMarkOverlay', Instigator,,Instigator.Location, Instigator.Rotation);
        }
    }

    function EndState()
    {
        Super.EndState();

        if(!bRestarting)
        {
            if(!bOldAlwaysRelevant)
                Instigator.bAlwaysRelevant = false;

            if(Mark != None)
                Mark.Destroy();
        }
    }
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    //Randomly multiply damage
    Damage *= 1.0 + (BaseDamageMult + Rand(7) * 0.01);
}

defaultproperties
{
    BaseDamageMult=0.04
    Duration=3.00
    bAllowOnSelf=False
    bAllowOnTeammates=False
}
