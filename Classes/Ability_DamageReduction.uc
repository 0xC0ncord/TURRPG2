//=============================================================================
// Ability_DamageReduction.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_DamageReduction extends RPGAbility;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Injured != InstigatedBy)
    {
        if(bIsStat)
            Damage += Ceil(float(AbilityLevel) * BonusPerLevel) - 1;
        else
            Damage = float(Damage) * (1.0 - float(AbilityLevel) * BonusPerLevel);
    }
}

simulated function string DescriptionText()
{
    if(bIsStat)
        return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatFloat(BonusPerLevel));
    else
        return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Damage Reduction"
    Description="Reduces all damage you take by $1 per level."
    MaxLevel=500
    StartingCost=1
    BonusPerLevel=0.2
    Category=class'AbilityCategory_Damage'
}
