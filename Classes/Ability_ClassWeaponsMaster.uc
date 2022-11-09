//=============================================================================
// Ability_ClassWeaponsMaster.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ClassWeaponsMaster extends RPGClass;

defaultproperties
{
    ClassTreeInfos(0)=(AbilityClass=Class'Ability_ClassWeaponsMaster',Row=1,Column=5,RequiredByAbilities=((Index=1,Levels=((Level=1))),(Index=2,Levels=((Level=1))),(Index=3,Levels=((Level=1))),(Index=4,Levels=((Level=1,TargetLevel=1))),(Index=6,Levels=((Level=1))),(Index=7,Levels=((Level=1)))))
    ClassTreeInfos(1)=(AbilityClass=Class'Ability_LoadedWeapons',Row=3,Column=5)
    ClassTreeInfos(2)=(AbilityClass=Class'Ability_AmmoRegen',Row=3,Column=6)
    ClassTreeInfos(3)=(AbilityClass=Class'Ability_Vampire',Row=3,Column=7,RequiredByAbilities=((Index=5,Levels=((Level=1)))))
    ClassTreeInfos(4)=(AbilityClass=Class'Ability_Denial',Row=3,Column=8)
    ClassTreeInfos(5)=(AbilityClass=Class'Ability_ComboHuntersRage',Row=5,Column=7)
    ClassTreeInfos(6)=(AbilityClass=Class'Ability_Awareness',Row=3,Column=9)
    ClassTreeInfos(7)=(AbilityClass=Class'Ability_LoadedAugments',Row=3,Column=2,RequiredByAbilities=((Index=8,Levels=((Level=1))),(Index=9,Levels=((Level=1))),(Index=10,Levels=((Level=1)))))
    ClassTreeInfos(8)=(AbilityClass=Class'Ability_ArtificerCharmAlpha',Row=5,Column=1)
    ClassTreeInfos(9)=(AbilityClass=Class'Ability_ArtificerCharmBeta',Row=5,Column=2)
    ClassTreeInfos(10)=(AbilityClass=Class'Ability_ArtificerCharmGamma',Row=5,Column=3)
    AbilityName="Class: Weapons Master"
    Description="Master of damage output. Has abilities to obtain nearly all weapons and utilize them efficiently to frag everything in the way."
    IconMaterial=Texture'ClWeaponsMasterIcon'
}
