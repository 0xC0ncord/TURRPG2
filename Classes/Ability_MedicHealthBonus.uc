//=============================================================================
// Ability_MedicHealthBonus.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MedicHealthBonus extends RPGAbility;

function ModifyPawn(Pawn Other)
{
    local float HealthBonus;

    Super.ModifyPawn(Other);

    HealthBonus = AbilityLevel * BonusPerLevel;

    Other.Health = Other.Health * (1 + HealthBonus);
    Other.HealthMax = Other.HealthMax * (1 + HealthBonus);
    Other.SuperHealthMax = Other.HealthMax + (Other.SuperHealthMax - Other.HealthMax);
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Medic's Constitution"
    Description="Increases your cumulative total starting and maximum health by $1 per level."
    StartingCost=5
    MaxLevel=10
    BonusPerLevel=0.050000
    Category=Class'AbilityCategory_Medic'
}
