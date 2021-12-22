//=============================================================================
// Ability_MultiCombo.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MultiCombo extends RPGAbility;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);

    if(RPGPawn(Other) != None)
    {
        RPGPawn(Other).bCanMultiCombo = true;
    }
}

defaultproperties
{
    AbilityName="Multi-Combo"
    Description="With this ability, you can have multiple adrenaline combos active at once."
    MaxLevel=1
    StartingCost=50
    Category=class'AbilityCategory_Adrenaline'
}
