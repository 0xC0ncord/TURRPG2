//=============================================================================
// Ability_Retaliation.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_Retaliation extends RPGAbility;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int RetalDamage;

    if(DamageType == class'DamTypeCounterShove' || DamageType == class'DamTypeRetaliation')
        return;

    if(Injured == InstigatedBy || Injured.Controller.SameTeamAs(InstigatedBy.Controller))
        return;

    RetalDamage = float(AbilityLevel) * BonusPerLevel * float(Damage);
    RetalDamage = Min(RetalDamage, Injured.Health);

    if(RetalDamage > 0)
    {
        InstigatedBy.TakeDamage(
            RetalDamage,
            Injured,
            InstigatedBy.Location,
            vect(0, 0, 0),
            class'DamTypeRetaliation');
    }
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=0.05
    AbilityName="Retaliation"
    Description="Whenever you are damaged by an opponent, $1 of the damage per level is also done to the opponent who hurt you. This ability does not retaliate against Retaliation or Counter Shove."
    StartingCost=10
    CostAddPerLevel=5
    MaxLevel=10
    ForbiddenAbilities(0)=(AbilityClass=class'Ability_CounterShove',Level=1)
    Category=class'AbilityCategory_Damage'
}
