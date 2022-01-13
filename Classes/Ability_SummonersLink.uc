//=============================================================================
// Ability_SummonersLink.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_SummonersLink extends RPGAbility;

var config float HealthBonusMax;
var config int HealthBonusAbsoluteCap;

//Real health gain - health will be granted once this hits a value of 1
var float RealHealthGain;

var localized string AbsoluteCapText;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    RealHealthGain = 0; //reset on respawn
}

function AdjustTargetDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Injured,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    local Pawn HealMe;
    local int HealthBonus, HealthGain, HealthBefore;
    local float Vampire;
    local FX_SummonersLinkBolt FX;

    if(RPRI.Controller.Pawn == None || RPRI.Controller.Pawn.Health <= 0)
        return;

    if(!class'DevoidEffect_Vampire'.static.CanBeApplied(Injured, InstigatedBy.Controller))
      return;

    if(
        Monster(InstigatedBy) != None
        && PlayerController(InstigatedBy.Controller) == None
        && VSize(InstigatedBy.Location - RPRI.Controller.Pawn.Location) <= 1024
    )
    {
        Vampire = FMax(FMin(float(Injured.Health), float(Damage) * BonusPerLevel * float(AbilityLevel)), 0);
        if(Vampire > 0)
        {
            RealHealthGain += Vampire;

            if(RealHealthGain > 1)
            {
                HealthGain = int(RealHealthGain);
                RealHealthGain -= float(HealthGain); //keeps the fraction

                HealMe = RPRI.Controller.Pawn;

                HealthBonus = HealMe.HealthMax * HealthBonusMax;
                if(HealthBonusAbsoluteCap > 0)
                    HealthBonus = Min(HealthBonus, HealthBonusAbsoluteCap);
                HealthBefore = HealMe.Health;
                HealMe.GiveHealth(HealthGain, HealMe.HealthMax + HealthBonus);
                if(HealMe.Health != HealthBefore)
                {
                    FX = Spawn(class'FX_SummonersLinkBolt', HealMe,, HealMe.Location, rotator(InstigatedBy.Location - HealMe.Location));
                    if(FX != None)
                    {
                        FX.Target = InstigatedBy;
                        if(Level.NetMode != NM_DedicatedServer)
                            FX.DoEffects();
                    }
                }
            }
        }
    }

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
}

simulated function string DescriptionText()
{
    local string Text;

    Text = Repl(
        Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel)),
        "$2", class'Util'.static.FormatPercent(HealthBonusMax));

    if(HealthBonusAbsoluteCap > 0)
        Text = Repl(Text, "$3", Repl(AbsoluteCapText, "$4", HealthBonusAbsoluteCap));
    else
        Text = Repl(Text, "$3", "");

    return Text;
}

defaultproperties
{
    StartingCost=1
    CostAddPerLevel=1
    MaxLevel=10
    HealthBonusMax=0.333333
    BonusPerLevel=0.025000
    AbsoluteCapText=" or maximally +$4"
    AbilityName="Summoner's Link"
    Description="Whenever one of your summoned monsters within a localized range of you damages an opponent, you are healed for $1 of the damage per level (up to your starting health amount +$2$3)."
    Category=Class'AbilityCategory_Monsters'
}
