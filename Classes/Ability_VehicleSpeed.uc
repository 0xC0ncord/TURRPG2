//=============================================================================
// Ability_VehicleSpeed.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_VehicleSpeed extends RPGAbility;

struct SpeedBonusStruct
{
    var class<ONSVehicle> VehicleType;
    var float Bonus;
};
var config array<SpeedBonusStruct> SpeedBonus;
var config float FallbackSpeedBonus;

var Vehicle ClientVehicle; //client-side only

var localized string DescriptionAmendment;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientModifyVehicle, ClientUnModifyVehicle;
}

simulated function ClientModifyVehicle(Vehicle V)
{
    if(Role < ROLE_Authority)
    {
        ClientVehicle = V;
        SetTimer(0.01f, false);
    }
}

simulated function Timer()
{
    if(ClientVehicle != None && Role < ROLE_Authority)
        ModifyVehicle(ClientVehicle);
}

simulated function ClientUnModifyVehicle(Vehicle V)
{
    if(Role < ROLE_Authority)
        UnModifyVehicle(V);
}

function ModifyVehicle(Vehicle V)
{
    local int i;
    local float Bonus;
    local Sync_ONSWeaponRotSpeed Sync;

    // turn speed

    Bonus = 1.0f + BonusPerLevel * float(AbilityLevel);

    if(Role == ROLE_Authority)
    {
        if(ONSVehicle(V) != None)
        {
            for(i = 0; i < ONSVehicle(V).Weapons.Length; i++)
            {
                Sync = Spawn(class'Sync_ONSWeaponRotSpeed');
                Sync.Target = ONSVehicle(V).Weapons[i];
                Sync.RotationsPerSecond = ONSVehicle(V).Weapons[i].RotationsPerSecond * Bonus;

                ONSVehicle(V).Weapons[i].RotationsPerSecond *= Bonus;
            }
        }

        if(ONSWeaponPawn(V) != None)
        {
            Sync = Spawn(class'Sync_ONSWeaponRotSpeed');
            Sync.Target = ONSWeaponPawn(V).Gun;
            Sync.RotationsPerSecond = ONSWeaponPawn(V).Gun.RotationsPerSecond * Bonus;

            ONSWeaponPawn(V).Gun.RotationsPerSecond *= Bonus;
        }

        if(ONSTreadCraft(V) != None)
            ONSTreadCraft(V).MaxSteerTorque *= Bonus;
    }

    if(ONSHoverCraft(V) != None)
    {
        ONSHoverCraft(V).TurnTorqueFactor *= Bonus;
        ONSHoverCraft(V).TurnTorqueMax *= Bonus;
        ONSHoverCraft(V).MaxYawRate *= Bonus;
    }

    if(ONSChopperCraft(V) != None)
    {
        ONSChopperCraft(V).TurnTorqueFactor *= Bonus;
        ONSChopperCraft(V).TurnTorqueMax *= Bonus;
        ONSChopperCraft(V).MaxYawRate *= Bonus;
    }

    if(Level.NetMode == NM_DedicatedServer)
        ClientModifyVehicle(V);

    // movement speed from here onwards

    if(ONSVehicle(V) == None)
        return;

    Bonus = 0;
    for(i = 0; i < SpeedBonus.Length; i++)
    {
        if(ClassIsChildOf(V.class, SpeedBonus[i].VehicleType))
        {
            Bonus = SpeedBonus[i].Bonus;
            break;
        }
    }

    if(Bonus <= 0)
        Bonus = FallbackSpeedBonus;

    Bonus = 1.0 + float(AbilityLevel) * Bonus;
    class'Util'.static.SetVehicleSpeed(V, Bonus);
}

simulated function UnModifyVehicle(Vehicle V)
{
    local Sync_ONSWeaponRotSpeed Sync;
    local int i;

    //Reset
    if(Role == ROLE_Authority)
    {
        if(ONSVehicle(V) != None)
        {
            for(i = 0; i < ONSVehicle(V).Weapons.Length; i++)
            {
                ONSVehicle(V).Weapons[i].RotationsPerSecond = ONSVehicle(V).Weapons[i].default.RotationsPerSecond;

                Sync = Spawn(class'Sync_ONSWeaponRotSpeed');
                Sync.Target = ONSVehicle(V).Weapons[i];
                Sync.RotationsPerSecond = ONSVehicle(V).Weapons[i].default.RotationsPerSecond;
            }
        }

        if(ONSWeaponPawn(V) != None)
        {
            ONSWeaponPawn(V).Gun.RotationsPerSecond = ONSWeaponPawn(V).Gun.default.RotationsPerSecond;

            Sync = Spawn(class'Sync_ONSWeaponRotSpeed');
            Sync.Target = ONSWeaponPawn(V).Gun;
            Sync.RotationsPerSecond = ONSWeaponPawn(V).Gun.default.RotationsPerSecond;
        }

        if(ONSTreadCraft(V) != None)
            ONSTreadCraft(V).MaxSteerTorque = ONSTreadCraft(V).default.MaxSteerTorque;
    }

    if(ONSHoverCraft(V) != None)
    {
        ONSHoverCraft(V).TurnTorqueFactor = ONSHoverCraft(V).default.TurnTorqueFactor;
        ONSHoverCraft(V).TurnTorqueMax = ONSHoverCraft(V).default.TurnTorqueMax;
        ONSHoverCraft(V).MaxYawRate = ONSHoverCraft(V).default.MaxYawRate;
    }

    if(ONSChopperCraft(V) != None)
    {
        ONSChopperCraft(V).TurnTorqueFactor = ONSChopperCraft(V).default.TurnTorqueFactor;
        ONSChopperCraft(V).TurnTorqueMax = ONSChopperCraft(V).default.TurnTorqueMax;
        ONSChopperCraft(V).MaxYawRate = ONSChopperCraft(V).default.MaxYawRate;
    }

    if(Level.NetMode == NM_DedicatedServer)
        ClientUnModifyVehicle(V);
}

simulated function string DescriptionText()
{
    local int i;
    local float MinBonus, MaxBonus;

    MinBonus = 1.0;
    MaxBonus = 0.0;

    for(i = 0; i < SpeedBonus.Length; i++)
    {
        if(SpeedBonus[i].Bonus > MaxBonus)
            MaxBonus = SpeedBonus[i].Bonus;

        if(SpeedBonus[i].Bonus < MinBonus)
            MinBonus = SpeedBonus[i].Bonus;
    }

    if(MinBonus == MaxBonus)
    {
        return repl(repl(
            repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(MinBonus)), "$2", ""),
            "$3", class'Util'.static.FormatPercent(BonusPerLevel));
    }
    else
    {
        return repl(repl(
            repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(MinBonus) @ "-" @ class'Util'.static.FormatPercent(MaxBonus)),
            "$2", default.DescriptionAmendment),
            "$3", class'Util'.static.FormatPercent(BonusPerLevel));
    }
}

defaultproperties
{
    AbilityName="Vehicular Swiftness"
    StatName="Vehicle Speed Bonus"
    Description="Increases your vehicle movement speed by $1 per level$2. Additionally, your vehicle or vehicle turret turning speed is increased by $1 per level."
    DescriptionAmendment=", dependent on the vehicle type"
    StartingCost=5
    MaxLevel=10
    FallbackSpeedBonus=0.05
    BonusPerLevel=0.10
    //NOTE: Order is very important here, as subclasses of the specified vehicle types will also count to offer mod compability!
    //So list the special classes first and the abstracts as fallbacks!!! ~pd
    SpeedBonus(0)=(VehicleType=class'Onslaught.ONSRV',Bonus=0.20) //Scorpion
    SpeedBonus(1)=(VehicleType=class'OnslaughtBP.ONSShockTank',Bonus=0.05) //Paladin
    SpeedBonus(2)=(VehicleType=class'OnslaughtBP.ONSDualAttackCraft',Bonus=0.10) //Cicada
    SpeedBonus(3)=(VehicleType=class'Onslaught.ONSChopperCraft',Bonus=0.20) //Raptor
    SpeedBonus(4)=(VehicleType=class'Onslaught.ONSHoverCraft',Bonus=0.05) //Manta
    SpeedBonus(5)=(VehicleType=class'Onslaught.ONSWheeledCraft',Bonus=0.10) //HellBender, SPMA, MAS, Toilet Car
    SpeedBonus(6)=(VehicleType=class'Onslaught.ONSTreadCraft',Bonus=0.10) //Tanks

    Category=class'AbilityCategory_Vehicles'
}
