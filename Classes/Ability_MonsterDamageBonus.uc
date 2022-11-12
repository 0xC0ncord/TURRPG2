//=============================================================================
// Ability_MonsterDamageBonus.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MonsterDamageBonus extends RPGAbility;

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
    if(
        Damage > 0
        && Monster(InstigatedBy) != None
        && FriendlyMonsterController(InstigatedBy.Controller) != None
        && Injured != FriendlyMonsterController(InstigatedBy.Controller).Master
    )
    {
        Damage += float(OriginalDamage) * float(AbilityLevel) * BonusPerLevel;
    }
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Monster Damage Bonus"
    Description="Increases all damage dealt by your summoned monsters by $1 per level."
    StartingCost=5
    MaxLevel=10
    BonusPerLevel=0.05
    Category=Class'AbilityCategory_Monsters'
}
