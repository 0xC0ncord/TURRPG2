//=============================================================================
// Ability_EnhancedMagicMaker.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_EnhancedMagicMaker extends RPGAbility;

defaultproperties
{
    AbilityName="Skilled Enchanting"
    Description="Grants you an Enhanced Magic Maker when you spawn, which allows you to choose a desired weapon modifier to generate. The chances of receiving that modifier become slightly increased, but are not guaranteed."
    StartingCost=20
    MaxLevel=1
    GrantItem(0)=(Level=1,InventoryClass=Class'Artifact_EnhancedMakeMagicWeapon_Selective')
    Category=Class'AbilityCategory_Artifacts'
}
