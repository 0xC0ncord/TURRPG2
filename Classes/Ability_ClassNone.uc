//=============================================================================
// Ability_ClassNone.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

// Abstract dummy class for building the class tree for abilities not pertinent to a class
class Ability_ClassNone extends RPGClass
    abstract;

defaultproperties
{
    ClassTreeInfos(0)=(AbilityClass=Class'Ability_Speed',Row=1,Column=1)
    ClassTreeInfos(1)=(AbilityClass=Class'Ability_Airmaster',Row=1,Column=3)
    ClassTreeInfos(2)=(AbilityClass=Class'Ability_DodgeSpeed',Row=1,Column=5)
    ClassTreeInfos(3)=(AbilityClass=Class'Ability_BoostDodging',Row=1,Column=7)
    ClassTreeInfos(4)=(AbilityClass=Class'Ability_JumpZ',Row=1,Column=9)
    ClassTreeInfos(5)=(AbilityClass=Class'Ability_MultiJump',Row=3,Column=1)
    ClassTreeInfos(6)=(AbilityClass=Class'Ability_ComboSuperSpeed',Row=3,Column=3)
    ClassTreeInfos(7)=(AbilityClass=Class'Ability_ComboHeal',Row=3,Column=5)
    ClassTreeInfos(8)=(AbilityClass=Class'Ability_ComboIronSpirit',Row=3,Column=7)
    ClassTreeInfos(9)=(AbilityClass=Class'Ability_ComboEthereal',Row=3,Column=9)
    ClassTreeInfos(10)=(AbilityClass=Class'Ability_Retaliation',Row=5,Column=1)
    ClassTreeInfos(11)=(AbilityClass=Class'Ability_CounterShove',Row=5,Column=3)
    ClassTreeInfos(12)=(AbilityClass=Class'Ability_Cautiousness',Row=5,Column=5)
    ClassTreeInfos(13)=(AbilityClass=Class'Ability_IronLegs',Row=5,Column=7)
    ClassTreeInfos(14)=(AbilityClass=Class'Ability_Chute',Row=5,Column=9)
    ClassTreeInfos(15)=(AbilityClass=Class'Ability_SmartHealing',Row=7,Column=1)
    ClassTreeInfos(16)=(AbilityClass=Class'Ability_Shield',Row=7,Column=3)
    ClassTreeInfos(17)=(AbilityClass=Class'Ability_Ammo',Row=9,Column=1)
    ClassTreeInfos(18)=(AbilityClass=Class'Ability_SpeedSwitcher',Row=9,Column=3)
    ClassTreeInfos(19)=(AbilityClass=Class'Ability_MultiRocket',Row=9,Column=5)
    ClassTreeInfos(20)=(AbilityClass=Class'Ability_TransAmmo',Row=9,Column=7)
    ClassTreeInfos(21)=(AbilityClass=Class'Ability_TransTossForce',Row=9,Column=9)
    ClassTreeInfos(22)=(AbilityClass=Class'Ability_Ghost',Row=11,Column=1)
    ClassTreeInfos(23)=(AbilityClass=Class'Ability_Ultima',Row=11,Column=3,ForbidsAbilities=((Index=24,Levels=((TargetLevel=1)))))
    ClassTreeInfos(24)=(AbilityClass=Class'Ability_UltimaShield',Row=11,Column=5,ForbidsAbilities=((Index=23,Levels=((TargetLevel=1)))))
    ClassTreeInfos(25)=(AbilityClass=Class'Ability_VehicleEject',Row=13,Column=1)
    ClassTreeInfos(26)=(AbilityClass=Class'Ability_WheeledVehicleStunts',Row=13,Column=3)
    ClassTreeInfos(27)=(AbilityClass=Class'Ability_Hardcore',Row=15,Column=1)
    ClassTreeInfos(28)=(AbilityClass=Class'Ability_ComboSiphon',Row=15,Column=3)
    ClassTreeInfos(29)=(AbilityClass=Class'Ability_ComboReflect',Row=15,Column=5)
    ClassTreeInfos(30)=(AbilityClass=Class'Ability_ComboNimble',Row=15,Column=7)
    ClassTreeInfos(31)=(AbilityClass=Class'Ability_ComboHolograph',Row=15,Column=9)
    ClassTreeInfos(32)=(AbilityClass=Class'Ability_AmmoBonus',Row=17,Column=1)
    AbilityName="Generic Abilities"
    Description="This message should not appear."
    IconMaterial=Texture'NYIIcon'
}
