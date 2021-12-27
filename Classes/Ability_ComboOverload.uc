//=============================================================================
// Ability_ComboOverload.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ComboOverload extends RPGAbility;

// explicitly make overload modify sentinels that were spawned
// after the combo was executed
function ModifyConstruction(Pawn P)
{
    local Vehicle V;
    local ComboOverload Combo;
    local int i;

    V = Vehicle(P);
    if(V == None)
        return;

    if(xPawn(RPRI.Controller.Pawn) == None)
        return;

    Combo = ComboOverload(xPawn(RPRI.Controller.Pawn).CurrentCombo);
    if(Combo == None && RPGPawn(RPRI.Controller.Pawn) != None)
        Combo = ComboOverload(RPGPawn(RPRI.Controller.Pawn).GetActiveCombo(class'ComboOverload'));
    if(Combo == None)
        return;

    for(i = 0; i < RPRI.Sentinels.Length; i++)
    {
        if(RPRI.Sentinels[i].Pawn == V)
        {
            Combo.ModifyVehicle(V);
            break;
        }
    }
}

defaultproperties
{
    ComboReplacements(0)=(ComboClasses=(class'ComboBerserk',class'RPGComboBerserk'),NewComboClass=class'ComboOverload')
    AbilityName="Overload"
    Description="Replaces the Berserk adrenaline combo with Overload, which not only increases your weapon fire speed, but also increases the fire speed of your constructed sentinels."
    MaxLevel=1
    StartingCost=20
    Category=class'AbilityCategory_Engineer'
}
