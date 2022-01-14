//=============================================================================
// Ability_ClassConjurer.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ClassConjurer extends RPGClass;

defaultproperties
{
    ClassTreeInfos(0)=(AbilityClass=Class'Ability_ClassConjurer',Row=1,Column=5,RequiredByAbilities=((Index=1,Levels=((Level=1))),(Index=6,Levels=((Level=1))),(Index=8,Levels=((Level=1,TargetLevel=3))),(Index=13,Levels=((Level=1)))))
    ClassTreeInfos(1)=(AbilityClass=Class'Ability_LoadedMonsters',Row=3,Column=2,RequiredByAbilities=((Index=2,Levels=((Level=1,TargetLevel=20)))))
    ClassTreeInfos(2)=(AbilityClass=Class'Ability_MonsterPoints',Row=5,Column=2,RequiredByAbilities=((Index=3,Levels=((Level=3))),(Index=4,Levels=((Level=3))),(Index=10,Levels=((Level=1))),(Index=9,Levels=((Level=1)))))
    ClassTreeInfos(3)=(AbilityClass=Class'Ability_MonsterHealth',Row=7,Column=1,RequiredByAbilities=((Index=5,Levels=((Level=1)))))
    ClassTreeInfos(4)=(AbilityClass=Class'Ability_MonsterSkill',Row=7,Column=4)
    ClassTreeInfos(5)=(AbilityClass=Class'Ability_MonstersMax',Row=9,Column=1)
    ClassTreeInfos(6)=(AbilityClass=Class'Ability_Metamorphosis',Row=3,Column=4,RequiredByAbilities=((Index=7,Levels=((Level=1)))))
    ClassTreeInfos(7)=(AbilityClass=Class'Ability_MetamorphosisRefund',Row=5,Column=4)
    ClassTreeInfos(8)=(AbilityClass=Class'Ability_AdrenalineSurge',Row=3,Column=8)
    ClassTreeInfos(9)=(AbilityClass=Class'Ability_MonsterDamageBonus',Row=7,Column=2,RequiredByAbilities=((Index=11,Levels=((Level=1)))))
    ClassTreeInfos(10)=(AbilityClass=Class'Ability_MonsterDamageReduction',Row=7,Column=3,RequiredByAbilities=((Index=12,Levels=((Level=1)))))
    ClassTreeInfos(11)=(AbilityClass=Class'Ability_MonsterUltima',Row=9,Column=2)
    ClassTreeInfos(12)=(AbilityClass=Class'Ability_SummonersLink',Row=9,Column=3)
    ClassTreeInfos(13)=(AbilityClass=Class'Ability_ConjurerVampire',Row=3,Column=6)
    AbilityName="Class: Conjurer"
    Description="Master of monsters. Can summon friendly monsters that fight for them, transform into monsters themselves, and ultimately perform necromancy."
    IconMaterial=Texture'ClConjurerIcon'
}
