//=============================================================================
// Ability_ComboHuntersRage.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboHuntersRage extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(ComboClasses=(class'ComboBerserk',class'RPGComboBerserk'),NewComboClass=class'ComboHuntersRage')
    AbilityName="Hunter's Rage"
    Description="Replaces the Berserk adrenaline combo with Hunter's Rage, which not only increases your weapon speed, but will also mark any nearby enemies, regardless of whether they are within view. Marked enemies will be easier to see and take increased damage from all friendly fire."
    MaxLevel=1
    StartingCost=40
    Category=class'AbilityCategory_Damage';
    IconMaterial=Texture'AbHuntersRageIcon'
}
