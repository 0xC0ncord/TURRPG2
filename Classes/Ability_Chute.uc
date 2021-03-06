//=============================================================================
// Ability_Chute.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_Chute extends RPGAbility;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    class'Util'.static.GiveInventory(Other, class'Artifact_Chute', true);
}

defaultproperties
{
    AbilityName="Parachute"
    Description="Gives you a parachute that you can open up if you are falling, softening your landing."
    StartingCost=10
    CostAddPerLevel=0
    MaxLevel=1
    Category=class'AbilityCategory_Misc'
}
