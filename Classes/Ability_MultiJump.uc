//=============================================================================
// Ability_MultiJump.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MultiJump extends RPGAbility;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);

    if(xPawn(Other) != None)
    {
        // Increase the number of times a player can jump in mid air
        xPawn(Other).MaxMultiJump = 1 + AbilityLevel;
        xPawn(Other).MultiJumpRemaining = 1 + AbilityLevel;

        // Also increase a bit the amount they jump each time
        //xPawn(Other).MultiJumpBoost = BonusPerLevel * AbilityLevel;
    }
}

defaultproperties
{
    AbilityName="Multi Jump"
    Description="Increases the amount of combined jumps you can perform by one per level (e.g. triple jump, quad jump, etc)."
    MaxLevel=7
    StartingCost=10
    BonusPerLevel=50
    Category=class'AbilityCategory_Movement'
}
