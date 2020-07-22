//=============================================================================
// Ability_ConstructionRange.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ConstructionRange extends RPGAbility;

function ModifyConstruction(Pawn Other)
{
    if(Vehicle(Other) != None && Vehicle(Other).bNonHumanControl && Other.Controller != None)
    {
        Other.SightRadius = Other.default.SightRadius * (1 + (AbilityLevel * BonusPerLevel));
        if(RPGBaseSentinelController(Other.Controller) != None)
        {
            RPGBaseSentinelController(Other.Controller).TargetRange = RPGBaseSentinelController(Other.Controller).default.TargetRange * (1 + (AbilityLevel * BonusPerLevel));
            RPGBaseSentinelController(Other.Controller).AttractRange = RPGBaseSentinelController(Other.Controller).default.AttractRange * (1 + (AbilityLevel * BonusPerLevel));
        }
        else if(RPGSentinelController(Other.Controller) != None)
        {
            RPGSentinelController(Other.Controller).TargetRange = RPGSentinelController(Other.Controller).default.TargetRange * (1 + (AbilityLevel * BonusPerLevel));
            RPGSentinelController(Other.Controller).AttractRange = RPGSentinelController(Other.Controller).default.AttractRange * (1 + (AbilityLevel * BonusPerLevel));
        }
        else if(RPGLightningSentinelController(Other.Controller) != None)
        {
            RPGLightningSentinelController(Other.Controller).TargetRadius = RPGLightningSentinelController(Other.Controller).default.TargetRadius * (1 + (AbilityLevel * BonusPerLevel));
        }
    }
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=0.05
    AbilityName="Target Acqusition Offloading"
    Description="For every level of this ability, your summoned offensive sentinels gain an additional $1 maximum targeting range. Defensive and utility sentinels are not affected by this ability."
    StartingCost=2
    CostAddPerLevel=1
    MaxLevel=10
    Category=class'AbilityCategory_Engineer'
}
