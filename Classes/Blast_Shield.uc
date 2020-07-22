//=============================================================================
// Blast_Shield.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Blast_Shield extends Blast;

var float MinBoosting, MaxBoosting;
var float EXPMultiplier;

function DoEffect()
{
    local float BoostingScale, Dist;
    local vector Dir;
    local Controller C;
    local Pawn P;
    local int BoostingLevel;
    local float ShieldBoostingPercent;
    local int ShieldGiven;
    local int CurShield;
    local int MaxShield;
    local Effect_ShieldBoost Shield;

    if(Instigator == None && InstigatorController != None)
        Instigator = InstigatorController.Pawn;

    GetBoostingStats(BoostingLevel, ShieldBoostingPercent);

    if(Instigator != None)
    {
        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(
                C.Pawn != None &&
                C.Pawn.Health > 0 &&
                VSize(C.Pawn.Location - Location) <= Radius &&
                FastTrace(C.Pawn.Location, Location)
            )
            {
                P = C.Pawn;

                if(bAffectInstigator || P != Instigator)
                {
                    //boost shields
                    Dir = C.Pawn.Location - Location;
                    Dist = FMax(1, VSize(Dir));
                    BoostingScale = 1 - FMax(0, Dist / Radius);

                    ShieldGiven = Max(1, (BoostingScale * (MaxBoosting - MinBoosting)) + MinBoosting);
                    if(ShieldGiven > 0)
                    {
                        CurShield = P.GetShieldStrength();
                        MaxShield = P.GetShieldStrengthMax();
                        if (CurShield < MaxShield)
                        {
                            Shield = Effect_ShieldBoost(class'Effect_ShieldBoost'.static.Create(P, Instigator.Controller));
                            if(Shield != None)
                            {
                                Shield.ShieldAmount = ShieldGiven;
                                Shield.BoostingLevel = BoostingLevel;
                                Shield.ShieldBoostingPercent = ShieldBoostingPercent;
                                Shield.Start();
                            }
                        }
                    }
                }
            }
        }
    }

    Destroy();
}

function GetBoostingStats(out int BoostingLevel, out float ShieldBoostingPercent)
{
    local Ability_ShieldBoosting Ability;
    local RPGPlayerReplicationInfo RPRI;

    if(Instigator != None)
    {
        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Instigator.Controller);
        if(RPRI != None)
        {
            Ability = Ability_ShieldBoosting(RPRI.GetOwnedAbility(class'Ability_ShieldBoosting'));
            if(Ability != None)
            {
                BoostingLevel = Ability.AbilityLevel;
                ShieldBoostingPercent = Ability.ShieldBoostingPercent;
            }
        }
    }
}

defaultproperties
{
    MaxBoosting=500.000000
    MinBoosting=100.000000
    ChargeTime=2.000000
    Radius=2200.000000
    ChargeEmitterClass=class'FX_BlastCharger_Shield_NEW'
    ExplosionClass=class'FX_BlastExplosion_Shield_NEW'
    bAffectInstigator=True
    bBotsBeAfraid=False
}
