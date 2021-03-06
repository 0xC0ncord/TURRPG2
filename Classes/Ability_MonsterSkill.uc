//=============================================================================
// Ability_MonsterSkill.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MonsterSkill extends RPGAbility;

function ModifyMonster(Monster M, Pawn Master)
{
    MonsterController(M.Controller).InitializeSkill(
        AIController(M.Controller).Skill + float(AbilityLevel) * BonusPerLevel);
}

defaultproperties
{
    BonusPerLevel=1
    AbilityName="Monster Intelligence"
    Description="Makes your summoned monsters more intelligent per level (increases their difficulty)."
    StartingCost=5
    CostAddPerLevel=5
    MaxLevel=5
    RequiredAbilities(0)=(AbilityClass=class'Ability_LoadedMonsters',Level=1)
    Category=class'AbilityCategory_Monsters'
}
