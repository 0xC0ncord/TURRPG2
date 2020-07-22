//=============================================================================
// Ability_ExpHealing.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ExpHealing extends RPGAbility;

function ModifyRPRI()
{
    RPRI.HealingExpMultiplier = RPRI.default.HealingExpMultiplier + (BonusPerLevel * float(AbilityLevel));
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Experienced Healing"
    Description="You gain $1 additional experience from healing per level."
    StartingCost=10
    MaxLevel=9
    RequiredAbilities(0)=(AbilityClass=class'Ability_LoadedMedic',Level=1)
    BonusPerLevel=0.01
    Category=class'AbilityCategory_Medic'
}
