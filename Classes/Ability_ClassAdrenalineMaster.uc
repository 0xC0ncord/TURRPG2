//=============================================================================
// Ability_ClassAdrenalineMaster.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ClassAdrenalineMaster extends RPGClass;

defaultproperties
{
    ClassTreeInfos(0)=(AbilityClass=Class'Ability_ClassAdrenalineMaster',Row=1,Column=5,RequiredByAbilities=((Index=1,Levels=((Level=1))),(Index=2,Levels=((Level=1))),(Index=3,Levels=((Level=1))),(Index=4,Levels=((Level=1))),(Index=5,Levels=((Level=1)))))
    ClassTreeInfos(1)=(AbilityClass=Class'Ability_LoadedArtifacts',Row=3,Column=2,RequiredByAbilities=((Index=6,Levels=((Level=4))),(Index=8,Levels=((Level=1)))))
    ClassTreeInfos(2)=(AbilityClass=Class'Ability_AdrenalineRegen',Row=3,Column=4)
    ClassTreeInfos(3)=(AbilityClass=Class'Ability_AdrenalineSurge',Row=3,Column=5)
    ClassTreeInfos(4)=(AbilityClass=Class'Ability_EnergyLeech',Row=3,Column=6)
    ClassTreeInfos(5)=(AbilityClass=Class'Ability_AmmoRegen',Row=3,Column=8,RequiredByAbilities=((Index=7,Levels=((Level=1)))))
    ClassTreeInfos(6)=(AbilityClass=Class'Ability_ArtifactMastery',Row=5,Column=1)
    ClassTreeInfos(7)=(AbilityClass=Class'Ability_Denial',Row=5,Column=8)
    ClassTreeInfos(8)=(AbilityClass=Class'Ability_EnhancedMagicMaker',Row=5,Column=3)
    AbilityName="Class: Adrenaline Master"
    Description="Master of magic weapons and artifacts."
    IconMaterial=Texture'ClAdrenalineMasterIcon'
}
