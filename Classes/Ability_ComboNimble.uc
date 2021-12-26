//=============================================================================
// Ability_ComboNimble.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboNimble extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(NewComboClass=class'ComboNimble')
    AbilityName="Nimble"
    Description="Allows you to perform the Nimble adrenaline combo, which makes you significantly lighter and more agile while airborne.||The Nimble combo can be activated with Forward, Forward, Left, Left."
    MaxLevel=1
    StartingCost=20
    Category=class'AbilityCategory_Adrenaline'
}
