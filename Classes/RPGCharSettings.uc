//=============================================================================
// RPGCharSettings.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//character-specific settings
class RPGCharSettings extends Object
    config(TURRPG2Settings)
    PerObjectConfig;

struct ArtifactOrderConfigStruct
{
    var string ArtifactID;
    var bool bShowAlways;
    var bool bNeverShow;
};
var config array<ArtifactOrderConfigStruct> ArtifactOrderConfig;

struct ArtifactRadialMenuConfigStruct
{
    var string ArtifactID;
    var bool bShowAlways;
};
var config array<ArtifactRadialMenuConfigStruct> ArtifactRadialMenuConfig;

struct FavoriteWeaponStruct
{
    var class<Weapon> WeaponClass;
    var class<RPGWeaponModifier> ModifierClass;
};
var config array<FavoriteWeaponStruct> FavoriteWeaponsConfig;

struct ArtificerAugmentStruct
{
    var class<ArtificerAugmentBase> AugmentClass;
    var int ModifierLevel;
};
var config array<ArtificerAugmentStruct> ArtificerCharmAlphaConfig;
var config array<ArtificerAugmentStruct> ArtificerCharmBetaConfig;
var config array<ArtificerAugmentStruct> ArtificerCharmGammaConfig;

defaultproperties
{
}
