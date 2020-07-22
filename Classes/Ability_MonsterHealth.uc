//=============================================================================
// Ability_MonsterHealth.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MonsterHealth extends RPGAbility;

function ModifyMonster(Monster M, Pawn Master)
{
    M.Health = int(float(M.Health) * (1.0f + float(AbilityLevel) * BonusPerLevel));
    M.SuperHealthMax = M.SuperHealthMax - M.HealthMax + M.Health;
    M.HealthMax = M.Health;
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Monster Fodder"
    Description="Increases your summoned monsters' health by $1 per level."
    BonusPerLevel=0.10
    StartingCost=5
    MaxLevel=10
    RequiredAbilities(0)=(AbilityClass=class'Ability_LoadedMonsters',Level=1)
    Category=class'AbilityCategory_Monsters'
}
