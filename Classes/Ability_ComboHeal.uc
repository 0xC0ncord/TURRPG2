//=============================================================================
// Ability_ComboHeal.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboHeal extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(ComboClasses=(class'ComboDefensive',class'RPGComboDefensive'),NewComboClass=class'ComboHeal')
    AbilityName="Heal Combo"
    Description="Replaces the Booster adrenaline combo with Heal, which will instantly grant you health and shields instead of replenishing them over time."
    MaxLevel=1
    StartingCost=20
    Category=class'AbilityCategory_Adrenaline'
}
