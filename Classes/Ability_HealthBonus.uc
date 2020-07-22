//=============================================================================
// Ability_HealthBonus.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_HealthBonus extends RPGAbility;

function ModifyPawn(Pawn Other)
{
    local int HealthBonus;

    Super.ModifyPawn(Other);

    HealthBonus = AbilityLevel * int(BonusPerLevel);

    Other.Health = Other.default.Health + HealthBonus;
    Other.HealthMax = Other.default.HealthMax + HealthBonus;
    Other.SuperHealthMax = Other.HealthMax + (Other.default.SuperHealthMax - Other.default.HealthMax);
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", int(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Health"
    StatName="Health Bonus"
    Description="Increases your starting and maximum health by $1 per level."
    MaxLevel=200
    StartingCost=1
    BonusPerLevel=1
    Category=class'AbilityCategory_Health'
}
