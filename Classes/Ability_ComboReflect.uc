//=============================================================================
// Ability_ComboReflect.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboReflect extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(NewComboClass=class'ComboReflect')
    AbilityName="Reflect"
    Description="Allows you to perform the Reflect adrenaline combo, which gives you a semi-permeable shield that periodically reflects enemy projectiles around you.||The Reflect combo can be activated with Back, Back, Left, Left."
    MaxLevel=1
    StartingCost=50
    Category=class'AbilityCategory_Adrenaline'
}
