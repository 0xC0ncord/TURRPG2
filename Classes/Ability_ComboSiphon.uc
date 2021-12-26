//=============================================================================
// Ability_ComboSiphon.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboSiphon extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(NewComboClass=class'ComboSiphon')
    AbilityName="Siphon"
    Description="Allows you to perform the Siphon adrenaline combo, which summons a floating orb above you that constantly drains the life force from your enemies and returns the damage to you as health.||The Siphon combo can be activated with Back, Back, Right, Right."
    MaxLevel=1
    StartingCost=50
    Category=class'AbilityCategory_Adrenaline'
}
