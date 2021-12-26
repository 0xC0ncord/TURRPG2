//=============================================================================
// ComboSiphonOrb.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboSiphonOrb extends Actor;

var float TargetRadius;

var float EffectInterval, NextEffectTime;
var int DamagePerInterval;

var FX_ComboSiphonOrb FX;
var FX_ComboSiphonBeam Beam;

simulated function PostNetBeginPlay()
{
    if(Level.NetMode != NM_DedicatedServer)
        FX = Spawn(class'FX_ComboSiphonOrb', self);
}

simulated function Destroyed()
{
    if(FX != None)
        FX.Kill();
    if(Beam != None)
        Beam.Kill();
}

simulated function Tick(float dt)
{
    local Pawn P, BestP;
    local float BestDist;
    local int OldHealth;
    local int HealAmount;

    if(Role == ROLE_Authority && Instigator == None)
    {
        Destroy();
        return;
    }

    SetLocation(Instigator.Location + vect(0, 0, 1) * (Instigator.CollisionHeight + 16));

    foreach Instigator.VisibleCollidingActors(class'Pawn', P, TargetRadius)
    {
        if(
            P != None
            && P.Health >= 0
            && !class'Util'.static.SameTeamP(Instigator, P)
            && (BestP == None || VSize(P.Location - Location) < BestDist)
        )
        {
            BestDist = VSize(P.Location - Location);
            BestP = P;
        }
    }

    if(BestP == None)
    {
        if(Beam != None)
            Beam.Kill();
        return;
    }

    if(Beam == None)
        Beam = Spawn(class'FX_ComboSiphonBeam', self,, Location);
    Beam.AimAt(BestP);

    if(Role < ROLE_Authority)
        return;

    if(NextEffectTime <= Level.TimeSeconds)
    {
        NextEffectTime = Level.TimeSeconds + EffectInterval;

        OldHealth = BestP.Health;
        BestP.TakeDamage(DamagePerInterval, Instigator, BestP.Location, vect(0, 0, 0), class'DamTypeComboSiphon');

        HealAmount = OldHealth - BestP.Health;

        OldHealth = Instigator.Health;
        Instigator.GiveHealth(HealAmount, Instigator.SuperHealthMax);
        if(OldHealth + HealAmount > Instigator.Health)
            Instigator.AddShieldStrength(OldHealth + HealAmount - Instigator.SuperHealthMax);
    }
}

defaultproperties
{
    TargetRadius=512.000000
    EffectInterval=0.500000
    DamagePerInterval=4
    RemoteRole=ROLE_SimulatedProxy
    bSkipActorPropertyReplication=True
    bHidden=True
}
