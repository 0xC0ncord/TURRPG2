//=============================================================================
// ComboSiphon.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboSiphon extends RPGCombo;

const MAX_TARGETS = 2;

var float TargetRadius;

var float EffectInterval, NextEffectTime;
var int DamagePerInterval;

var FX_ComboSiphon FX;

struct TargetStruct
{
    var Pawn Pawn;
    var FX_ComboSiphonSucker FX;
};
var array<TargetStruct> Targets;

static final function Pawn PopClosestTarget(vector Pivot, out array<Pawn> Targets)
{
    local int i;
    local int BestIdx;
    local float dist, BestDist;
    local Pawn P;

    for(i = 0; i < Targets.Length; i++)
    {
        dist = VSize(Targets[i].Location - Pivot);
        if(BestDist == 0 || dist < BestDist)
        {
            BestIdx = i;
            BestDist = dist;
        }
    }
    P = Targets[BestIdx];
    Targets.Remove(BestIdx, 1);
    return P;
}

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboSiphon', P,, P.Location);
}

function DestroyEffects(Pawn P)
{
    local int i;

    if(FX != None)
        FX.ClientKill();
    for(i = 0; i < Targets.Length; i++)
        if(Targets[i].FX != None)
            Targets[i].FX.ClientKill();
}

function Tick(float dt)
{
    local Pawn P;
    local array<Pawn> PList, BestPList;
    local int i, x;
    local int OldHealth;
    local int HealAmount;
    local int NumTargets;

    if(Instigator == None)
    {
        Destroy();
        return;
    }

    Super.Tick(dt);

    //find all nearby available targets
    foreach Instigator.CollidingActors(class'Pawn', P, TargetRadius)
    {
        if(
            P != None
            && P.Health >= 0
            && !class'Util'.static.SameTeamP(Instigator, P)
            && FastTrace(P.Location, Instigator.Location)
        )
        {
            PList[PList.Length] = P;
        }
    }

    //filter down to the closest targets
    if(PList.Length <= MAX_TARGETS)
    {
        BestPList = PList;
        NumTargets = PList.Length;
    }
    else
    {
        while(NumTargets < MAX_TARGETS)
        {
            BestPList[BestPList.Length] = static.PopClosestTarget(Instigator.Location, PList);
            NumTargets++;
        }
    }

    //no targets, so just clear all existing ones
    if(NumTargets == 0)
    {
        i = Targets.Length - 1;
        while(i >= 0)
        {
            if(Targets[i].FX != None)
                Targets[i].FX.ClientKill();
            Targets.Remove(i--, 1);
        }
        return;
    }

    //check if these targets are already known, clean up fx if now invalid target
    i = 0;
    while(i < Targets.Length)
    {
        for(x = 0; x < BestPList.Length; x++)
        {
            if(Targets[i].Pawn == BestPList[x])
            {
                //nothing to do
                BestPList.Remove(x, 1);
                x = -1;
                break;
            }
        }

        //old target is now invalid
        if(x != -1)
        {
            if(Targets[i].FX != None)
                Targets[i].FX.ClientKill();
            Targets.Remove(i, 1);
        }
        else
            i++;
    }

    //add the new targets
    for(i = 0; i < BestPList.Length; i++)
    {
        x = Targets.Length;
        Targets.Length = x + 1;
        Targets[x].Pawn = BestPList[i];
        Targets[x].FX = Spawn(class'FX_ComboSiphonSucker', BestPList[i],, BestPList[i].Location, rotator(Location - BestPList[i].Location));
        Targets[x].FX.AimTarget = Instigator;
    }

    //do damage
    if(NextEffectTime <= Level.TimeSeconds)
    {
        NextEffectTime = Level.TimeSeconds + EffectInterval;

        for(i = 0; i < NumTargets; i++)
        {
            OldHealth = Targets[i].Pawn.Health;
            Targets[i].Pawn.TakeDamage(Max(1, DamagePerInterval / NumTargets), Instigator, Targets[i].Pawn.Location, vect(0, 0, 0), class'DamTypeComboSiphon');

            HealAmount = OldHealth - Targets[i].Pawn.Health;

            OldHealth = Instigator.Health;
            Instigator.GiveHealth(HealAmount, Instigator.SuperHealthMax);
            if(OldHealth + HealAmount > Instigator.Health)
                Instigator.AddShieldStrength(OldHealth + HealAmount - Instigator.SuperHealthMax);
        }
    }
}

defaultproperties
{
    TargetRadius=512.000000
    EffectInterval=0.500000
    DamagePerInterval=4
    ExecMessage="Siphon!"
    ComboAnnouncementName="ComboSiphon"
    keys(0)=4
    keys(1)=4
    keys(2)=2
    keys(3)=2
}
