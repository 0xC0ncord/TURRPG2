//=============================================================================
// Ability_VehicleEject.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_VehicleEject extends RPGAbility;

var config array<class<DamageType> > ProtectAgainst;
var config array<float> EjectCooldown; //can't enter a vehicle before this time has passed
var config bool bResetTranslocatorCharge;

var float LastEjectionTime;
var float NextVehicleTime;

var Sound CantEnterSound;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientNotifyCooldown;
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(HasJustEjected() && class'Util'.static.InArray(DamageType, ProtectAgainst) >= 0)
        Damage = 0;
}

function bool CanEjectDriver(Vehicle KilledVehicle)
{
    return Level.TimeSeconds >= NextVehicleTime;
}

function bool HasJustEjected()
{
    return ((Level.TimeSeconds - LastEjectionTime) < 2.0f);
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented)
{
    local TransLauncher TL;
    local Pawn Driver;
    local Vehicle V;
    local vector EjectVel;

    //check if we're still on cooldown
    if(Level.TimeSeconds < NextVehicleTime)
        return false;

    V = Vehicle(Killed);

    if(V == None)
        return false; //to fix the weird survival / spectator bug

    Driver = V.Driver;

    if(DamageType == class'DamTypeSelfDestruct' || Driver == None || !CanEjectDriver(V))
        return false;

    if(HasJustEjected())
        return false;

    V.KDriverLeave( true );

    EjectVel = VRand();
    EjectVel.Z = 0;
    EjectVel = (Normal(EjectVel) * 0.2 + Vect(0, 0, 1)) * class'ONSHoverBike'.default.EjectMomentum;

    Driver.Velocity = EjectVel;
    Driver.PlayTeleportEffect( false, false);

    LastEjectionTime = Level.TimeSeconds;

    if(EjectCooldown[AbilityLevel - 1] > 0)
    {
        NextVehicleTime = Level.TimeSeconds + EjectCooldown[AbilityLevel - 1];
        ClientNotifyCooldown(EjectCooldown[AbilityLevel - 1]);
    }

    if(bResetTranslocatorCharge)
    {
        TL = TransLauncher(Driver.FindInventoryType(class'TransLauncher'));
        if(TL != None)
        {
            //TL.DrainCharges(); //BR-like is a little too harsh, setting ammo to -1
            TL.AmmoChargeF = 0;
            TL.RepAmmo = 0;
            TL.bDrained = false;
            TL.Enable('Tick'); //start recharging
        }
    }

    return false; //NOT saving the vehicle
}

simulated function ClientNotifyCooldown(float Time)
{
    //simulated client-side so status icon can use it correctly
    NextVehicleTime = Level.TimeSeconds + Time;
}

defaultproperties
{
    StatusIconClass=class'StatusIcon_VehicleEject'
    CantEnterSound=Sound'TURRPG2.Interface.CantUse'
    bResetTranslocatorCharge=True
    EjectCooldown(0)=300.00
    EjectCooldown(1)=180.00
    EjectCooldown(2)=60.00
    EjectCooldown(3)=0.00
    AbilityName="Ejector Seat"
    Description="Ejects you from your vehicle when it's destroyed."
    LevelDescription(0)="Level 1 ejects you from any seat in a vehicle as well as from any defensive turret when it is destroyed. This effect will not activate again until after a cooldown of 5 minutes.."
    LevelDescription(1)="Level 2 reduces the cooldown to 3 minutes."
    LevelDescription(2)="Level 3 reduces the cooldown to 1 minute."
    LevelDescription(3)="Level 4 eliminates the cooldown entirely."
    MaxLevel=4
    bUseLevelCost=true
    LevelCost(0)=10
    LevelCost(1)=5
    LevelCost(2)=5
    LevelCost(3)=5
    ProtectAgainst(0)=class'Onslaught.DamTypeONSVehicle'
    ProtectAgainst(1)=class'Onslaught.DamTypeONSVehicleExplosion'
    ProtectAgainst(2)=class'Onslaught.DamTypeDestroyedVehicleRoadKill'
    ProtectAgainst(3)=class'Onslaught.DamTypeTankShell'
    ProtectAgainst(4)=class'OnslaughtBP.DamTypeShockTankShockBall'
    ProtectAgainst(5)=class'OnslaughtBP.DamTypeArtilleryShell'
    ProtectAgainst(6)=class'OnslaughtFull.DamTypeMASCannon'
    ProtectAgainst(7)=class'OnslaughtFull.DamTypeIonTankBlast'
    ProtectAgainst(8)=class'XWeapons.DamTypeIonBlast'
    ProtectAgainst(9)=class'XWeapons.DamTypeRedeemer'
    ProtectAgainst(10)=class'DamTypeTitanUltima'
    ProtectAgainst(11)=class'DamTypeUltima'
    Category=class'AbilityCategory_Vehicles'
}
