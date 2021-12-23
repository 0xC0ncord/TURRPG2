//=============================================================================
// Ability_ComboIronSpirit.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboIronSpirit extends RPGAbility;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Injured == RPRI.Controller.Pawn)
    {
        if(
            (xPawn(Injured) != None && ComboIronSpirit(xPawn(Injured).CurrentCombo) != None)
            || (RPGPawn(Injured) != None && RPGPawn(Injured).GetActiveCombo(class'ComboIronSpirit') != None)
        )
        {
            Momentum *= (1.0 - (BonusPerLevel * AbilityLevel));
            Damage *= (1.0 - (BonusPerLevel * AbilityLevel));
        }
    }
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(default.BonusPerLevel));
}

defaultproperties
{
    ComboReplacements(0)=(NewComboClass=class'ComboIronSpirit')
    BonusPerLevel=0.100000
    AbilityName="Iron Spirit"
    Description="Allows you to perform the Iron Spirit adrenaline combo, which will decrease all momentum and damage done to you. Each level of this this ability will add +$1 to your total momentum reduction and damage reduction while Iron Spirit is active.||The Iron Spirit combo can be activated with Left, Left, Right, Right."
    MaxLevel=5
    LevelCost(0)=50
    LevelCost(1)=10
    LevelCost(2)=20
    LevelCost(3)=30
    LevelCost(4)=40
    Category=class'AbilityCategory_Damage';
}
