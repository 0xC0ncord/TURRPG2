//=============================================================================
// Ability_VehicleVampire.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_VehicleVampire extends Ability_Vampire;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Injured == InstigatedBy || Vehicle(InstigatedBy) == None || Vehicle(InstigatedBy).Driver == None)
        return;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{
    AbilityName="Vehicle Vampirism"
    Description="Whenever you damage an opponent from a vehicle or turret, it gets repaired for $1 of the damage per level (up to its starting health amount + $2$3). Sentinels and other automated vehicles cannot gain health from this ability. This ability is not triggered by artifact damage. You cannot gain health from self-damage."
    BonusPerLevel=0 //none on foot
    VehicleBonusPerLevel=0.050000
    HealthBonusMax=0.500000
    HealthBonusAbsoluteCap=1000
    MaxLevel=10
    bUseLevelCost=true
    LevelCost(0)=5
    LevelCost(1)=10
    LevelCost(2)=15
    LevelCost(3)=20
    LevelCost(4)=25
    LevelCost(5)=25
    LevelCost(6)=25
    LevelCost(7)=25
    LevelCost(8)=25
    LevelCost(9)=25
    Category=class'AbilityCategory_Vehicles'
    IconMaterial=Texture'AbVehicleVampire'
}
