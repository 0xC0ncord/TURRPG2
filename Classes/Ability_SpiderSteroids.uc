//=============================================================================
// Ability_SpiderSteroids.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_SpiderSteroids extends RPGAbility;

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
        EGun.SpiderBoostLevel = AbilityLevel * default.BonusPerLevel;

    Super.ModifyPawn(Other);
}

function ModifyConstruction(Pawn Other)
{
    if(RPGDefenseSentinel(Other) != None)
        RPGDefenseSentinel(Other).SpiderBoostLevel = AbilityLevel * default.BonusPerLevel;
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Spider Steroids"
    Description="Allows the Engineer Link Gun to boost spider mines. For every level of this ability, you can boost spider mines by an additional $1."
    MaxLevel=10
    StartingCost=20
    BonusPerLevel=0.200000
    Category=class'AbilityCategory_Engineer'
}
