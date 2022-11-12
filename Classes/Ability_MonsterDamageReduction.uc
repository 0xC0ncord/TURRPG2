//=============================================================================
// Ability_MonsterDamageReduction.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MonsterDamageReduction extends RPGAbility;

function AdjustPlayerDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Injured,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    if(
        Damage > 0
        && Monster(Injured) != None
        && FriendlyMonsterController(Injured.Controller) != None
        && InstigatedBy != FriendlyMonsterController(Injured.Controller).Master
    )
    {
        Damage = Max(0, Damage - (float(OriginalDamage) * float(AbilityLevel) * BonusPerLevel));
    }
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Monster Damage Reduction"
    Description="Reduces all damage taken by your summoned monsters by $1 per level."
    StartingCost=3
    MaxLevel=10
    BonusPerLevel=0.025
    Category=Class'AbilityCategory_Monsters'
}
