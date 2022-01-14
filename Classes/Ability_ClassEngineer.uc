//=============================================================================
// Ability_ClassEngineer.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ClassEngineer extends RPGClass;

defaultproperties
{
    ClassTreeInfos(0)=(AbilityClass=Class'Ability_ClassEngineer',Row=1,Column=5,RequiredByAbilities=((Index=1,Levels=((Level=1))),(Index=2,Levels=((Level=1))),(Index=10,Levels=((Level=1))),(Index=11,Levels=((Level=1))),(Index=13,Levels=((Level=1)))))
    ClassTreeInfos(1)=(AbilityClass=Class'Ability_LoadedEngineer',Row=3,Column=2,RequiredByAbilities=((Index=3,Levels=((Level=1))),(Index=5,Levels=((Level=1))),(Index=6,Levels=((Level=1))),(Index=7,Levels=((Level=1)))))
    ClassTreeInfos(2)=(AbilityClass=Class'Ability_ShieldRegen',Row=7,Column=5,RequiredByAbilities=((Index=15,Levels=((Level=1)))))
    ClassTreeInfos(3)=(AbilityClass=Class'Ability_ShieldBoosting',Row=3,Column=4,RequiredByAbilities=((Index=4,Levels=((Level=1)))))
    ClassTreeInfos(4)=(AbilityClass=Class'Ability_ShieldAura',Row=5,Column=4)
    ClassTreeInfos(5)=(AbilityClass=Class'Ability_ConstructionHealth',Row=5,Column=1)
    ClassTreeInfos(6)=(AbilityClass=Class'Ability_ConstructionDamage',Row=5,Column=2,RequiredByAbilities=((Index=8,Levels=((Level=1)))))
    ClassTreeInfos(7)=(AbilityClass=Class'Ability_ConstructionRange',Row=5,Column=3)
    ClassTreeInfos(8)=(AbilityClass=Class'Ability_ComboOverload',Row=7,Column=2)
    ClassTreeInfos(9)=(AbilityClass=Class'Ability_WheeledVehicleStunts',Row=5,Column=9)
    ClassTreeInfos(10)=(AbilityClass=Class'Ability_VehicleEject',Row=3,Column=8)
    ClassTreeInfos(11)=(AbilityClass=Class'Ability_VehicleArmor',Row=3,Column=7,RequiredByAbilities=((Index=12,Levels=((Level=1)))))
    ClassTreeInfos(12)=(AbilityClass=Class'Ability_VehicleRegen',Row=5,Column=7,RequiredByAbilities=((Index=14,Levels=((Level=1)))))
    ClassTreeInfos(13)=(AbilityClass=Class'Ability_VehicleSpeed',Row=3,Column=9,RequiredByAbilities=((Index=9,Levels=((Level=1)))))
    ClassTreeInfos(14)=(AbilityClass=Class'Ability_VehicleVampire',Row=7,Column=7)
    ClassTreeInfos(15)=(AbilityClass=Class'Ability_ShieldVampire',Row=9,Column=5)
    AbilityName="Class: Engineer"
    Description="Capable of constructing turrets, sentinels, vehicles, bases, and utilities for themselves and their teammates."
    IconMaterial=Texture'ClEngineerIcon'
}
