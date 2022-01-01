//=============================================================================
// Ability_ComboHolograph.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboHolograph extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(NewComboClass=class'ComboHolograph')
    AbilityName="Holograph"
    Description="Allows you to perform the Holograph adrenaline combo, which summons a holographic dummy target that distracts enemy monsters.||The Holograph combo can be activated with Forward, Forward, Right, Right."
    MaxLevel=1
    StartingCost=20
    Category=class'AbilityCategory_Adrenaline'
}
