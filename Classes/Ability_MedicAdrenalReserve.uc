//=============================================================================
// Ability_MedicAdrenalReserve.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MedicAdrenalReserve extends RPGAbility;

var int AdrenalineAmount;
var bool bAdrenalineGiven;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);

    if(!bAdrenalineGiven)
    {
        bAdrenalineGiven = true;
        RPRI.AwardAdrenaline(AdrenalineAmount, Self);
    }
}

function PlayerDied(bool bLogout, optional Pawn Killer, optional class<DamageType> DamageType)
{
    bAdrenalineGiven = false;
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", AdrenalineAmount);
}

defaultproperties
{
    AdrenalineAmount=10
    AbilityName="Medic Adrenal Reserve"
    Description="Allows you to start with $1 adrenaline when you spawn so that you can roll your Medic weapon immediately."
    StartingCost=10
    MaxLevel=1
    Category=Class'AbilityCategory_Medic'
}
