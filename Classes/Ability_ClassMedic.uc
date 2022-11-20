//=============================================================================
// Ability_ClassMedic.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ClassMedic extends RPGClass;

defaultproperties
{
    ClassTreeInfos(0)=(AbilityClass=Class'Ability_ClassMedic',Row=1,Column=5,RequiredByAbilities=((Index=1,Levels=((Level=1))),(Index=2,Levels=((Level=1))),(Index=3,Levels=((Level=1)))))
    ClassTreeInfos(1)=(AbilityClass=Class'Ability_LoadedMedic',Row=3,Column=3,RequiredByAbilities=((Index=4,Levels=((Level=1))),(Index=5,Levels=((Level=1))),(Index=6,Levels=((Level=1))),(Index=7,Levels=((Level=1))),(Index=8,Levels=((Level=1)))))
    ClassTreeInfos(2)=(AbilityClass=Class'Ability_Regen',Row=3,Column=7,RequiredByAbilities=((Index=10,Levels=((Level=1)))))
    ClassTreeInfos(3)=(AbilityClass=Class'Ability_AdrenalineRegen',Row=3,Column=5)
    ClassTreeInfos(4)=(AbilityClass=Class'Ability_ExpHealing',Row=5,Column=1)
    ClassTreeInfos(5)=(AbilityClass=Class'Ability_MedicAdrenalReserve',Row=5,Column=2,RequiredByAbilities=((Index=11,Levels=((Level=1)))))
    ClassTreeInfos(6)=(AbilityClass=Class'Ability_MedicAura',Row=5,Column=5,RequiredByAbilities=((Index=9,Levels=((Level=1)))))
    ClassTreeInfos(7)=(AbilityClass=Class'Ability_ComboTeamBooster',Row=5,Column=4)
    ClassTreeInfos(8)=(AbilityClass=Class'Ability_MedicIncantation',Row=5,Column=3,RequiredByAbilities=((Index=12,Levels=((Level=1)))))
    ClassTreeInfos(9)=(AbilityClass=Class'Ability_MedicPledge',Row=7,Column=5,RequiredByAbilities=((Index=14,Levels=((Level=1)))))
    ClassTreeInfos(10)=(AbilityClass=Class'Ability_MedicHealthBonus',Row=5,Column=7)
    ClassTreeInfos(11)=(AbilityClass=Class'Ability_HealingAdrenaline',Row=7,Column=2)
    ClassTreeInfos(12)=(AbilityClass=Class'Ability_HealingFlames',Row=7,Column=3,RequiredByAbilities=((Index=13,Levels=((Level=1)))))
    ClassTreeInfos(13)=(AbilityClass=Class'Ability_HealingDefender',Row=9,Column=3)
    ClassTreeInfos(14)=(AbilityClass=Class'Ability_MedicMotes',Row=9,Column=5)
    AbilityName="Class: Medic"
    Description="Master of pure defense, regeneration, and buffing themselves and their teammates to keep the team alive."
    IconMaterial=Texture'ClMedicIcon'
}
