//=============================================================================
// Ability_AmmoBonus.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_AmmoBonus extends RPGAbility;

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
    if(Ammo(item) != None && Ammo(item).AmmoAmount > 0)
        Ammo(item).AmmoAmount += Ammo(item).AmmoAmount * BonusPerLevel * AbilityLevel;
    return false;
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Arms Race"
    Description="For each level of this ability, ammo pickups will replenish an additional $1 ammo to your weapons."
    StartingCost=2
    CostAddPerLevel=2
    MaxLevel=5
    BonusPerLevel=0.100000
    Category=Class'AbilityCategory_Weapons'
}
