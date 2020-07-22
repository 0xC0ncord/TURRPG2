//=============================================================================
// Ability_MonstersMax.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MonstersMax extends RPGAbility;

function ModifyRPRI()
{
    RPRI.MaxMonsters = RPRI.default.MaxMonsters + AbilityLevel;
}

defaultproperties
{
    AbilityName="Monster Herder"
    Description="For each level, you are allowed to spawn one additional monster."
    bUseLevelCost=True
    LevelCost(0)=5
    LevelCost(1)=5
    LevelCost(2)=10
    MaxLevel=3
    RequiredAbilities(0)=(AbilityClass=class'Ability_LoadedMonsters',Level=1)
    Category=class'AbilityCategory_Monsters'
}
