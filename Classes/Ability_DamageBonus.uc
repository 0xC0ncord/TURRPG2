//=============================================================================
// Ability_DamageBonus.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_DamageBonus extends RPGAbility;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Damage = float(Damage) * (1.0 + float(AbilityLevel) * BonusPerLevel);
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Damage Bonus"
    Description="Increases all damage you do by $1 per level."
    MaxLevel=500
    StartingCost=1
    BonusPerLevel=0.001
    Category=class'AbilityCategory_Damage'
}
