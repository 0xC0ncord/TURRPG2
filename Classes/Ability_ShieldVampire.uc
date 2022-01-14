//=============================================================================
// Ability_ShieldVampire.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ShieldVampire extends RPGAbility;

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
    local float Vampire;
    local Pawn P;

    if(DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None)
        return;

    if(Vehicle(Instigator) == None)
    {
        P = Instigator;
    }
    else
    {
        P = Vehicle(Instigator).Driver;
        if(P == None)
        {
            return;
        }
    }

    if(xPawn(Instigator).GetShieldStrength() == xPawn(Instigator).ShieldStrengthMax)
        return;

    Vampire = Damage;

    // only get vampire on damage we actually do
    if(Injured != None && Vampire > Injured.Health)
        Vampire = Injured.Health;

    Vampire *= BonusPerLevel * AbilityLevel;
    if(Vampire < 1.0 && Damage > 0)
    {
        Vampire = 1.0;
    }

    if(xPawn(Instigator).GetShieldStrength() + Vampire > xPawn(Instigator).ShieldStrengthMax)
        P.AddShieldStrength(xPawn(Instigator).ShieldStrengthMax - xPawn(Instigator).GetShieldStrength());
    P.AddShieldStrength(Vampire);
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=0.005000
    AbilityName="Shield Vampirism"
    Description="Whenever you damage an opponent, your shields are boosted for $1 of the damage per level (up to your maximum shield amount). You can't gain shields from self-damage and you can't gain shields from damage caused by the Retaliation ability."
    StartingCost=1
    CostAddPerLevel=1
    MaxLevel=20
    Category=Class'AbilityCategory_Engineer'
}
