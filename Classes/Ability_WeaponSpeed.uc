//=============================================================================
// Ability_WeaponSpeed.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_WeaponSpeed extends RPGAbility;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientModifyWeapon, ClientModifyVehicleWeaponFireRate;
}

function float GetModifier() {
    return 1.0 + (BonusPerLevel * AbilityLevel);
}

simulated function ClientModifyWeapon(Weapon Weapon, float Modifier)
{
    class'Util'.static.SetWeaponFireRate(Weapon, Modifier);
}

function ModifyWeapon(Weapon Weapon)
{
    local float Modifier;

    Modifier = GetModifier();

    class'Util'.static.SetWeaponFireRate(Weapon, Modifier);
    ClientModifyWeapon(Weapon, Modifier);
}

function ModifyVehicleFireRate(Vehicle V, float Modifier)
{
    local int i;
    local ONSVehicle OV;
    local ONSWeaponPawn WP;
    local Inventory Inv;

    OV = ONSVehicle(V);
    if (OV != None)
    {
        for(i = 0; i < OV.Weapons.length; i++)
        {
            class'Util'.static.SetVehicleWeaponFireRate(OV.Weapons[i], Modifier);
            ClientModifyVehicleWeaponFireRate(OV.Weapons[i], Modifier);
        }
    }
    else
    {
        WP = ONSWeaponPawn(V);
        if (WP != None)
        {
            class'Util'.static.SetVehicleWeaponFireRate(WP.Gun, Modifier);
            ClientModifyVehicleWeaponFireRate(WP.Gun, Modifier);
        }
        else //some other type of vehicle (usually ASVehicle) using standard weapon system
        {
            //at this point, the vehicle's Weapon is not yet set, but it should be its only inventory
            for(Inv = V.Inventory; Inv != None; Inv = Inv.Inventory)
            {
                if(Weapon(Inv)!=None)
                {
                    class'Util'.static.SetVehicleWeaponFireRate(Weapon(Inv), Modifier);
                    ClientModifyVehicleWeaponFireRate(Weapon(Inv), Modifier);
                }
            }
        }
    }
}

simulated function ClientModifyVehicleWeaponFireRate(Actor W, float Modifier)
{
    class'Util'.static.SetVehicleWeaponFireRate(W, Modifier);
}

function ModifyVehicle(Vehicle V)
{
    ModifyVehicleFireRate(V, GetModifier());
}

function UnModifyVehicle(Vehicle V)
{
    ModifyVehicleFireRate(V, 1.0);
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Weapon Speed"
    StatName="Weapon Speed Bonus"
    Description="Increases your firing rate for all weapons by $1 per level.|The Berserk adrenaline Combo will stack with this effect."
    MaxLevel=100
    StartingCost=1
    BonusPerLevel=0.01
    Category=class'AbilityCategory_Weapons'
}
