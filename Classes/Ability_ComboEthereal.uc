//=============================================================================
// Ability_ComboEthereal.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboEthereal extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(ComboClasses=(class'ComboInvis',class'RPGComboInvis'),NewComboClass=class'ComboEthereal')
    AbilityName="Ethereal"
    Description="Replaces the Invisibility adrenaline combo with Ethereal, which will allow you to pass through other enemies, other players, and all projectiles (but not melee damage)."
    MaxLevel=1
    StartingCost=50
    Category=class'AbilityCategory_Adrenaline'
}
