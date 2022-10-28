//=============================================================================
// Ability_TransRepair.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_TransRepair extends RPGAbility;

simulated function ModifyPawn(Pawn Other)
{
    local Inventory Inv;
    local WeaponModifier_EngineerLink EGun;

    EGun = None;
    for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if(ClassIsChildOf(Inv.Class, class'EngineerLinkGun'))
        {
            EGun = WeaponModifier_EngineerLink(class'WeaponModifier_EngineerLink'.static.GetFor(EngineerLinkGun(Inv)));
            break;
        }
    }
    if (EGun != None)
        EGun.bHasTransRepair = True;

    Super.ModifyPawn(Other);
}

function ModifyConstruction(Pawn Other)
{
    if(RPGDefenseSentinel(Other) != None)
        RPGDefenseSentinel(Other).bHasTransRepair = true;
}

defaultproperties
{
    AbilityName="Translocator Beacon Repair"
    Description="Allows the Engineer Link Gun to repair teammates' translocator beacons."
    StartingCost=5
    MaxLevel=1
    Category=Class'TURRPG2.AbilityCategory_Engineer'
}
