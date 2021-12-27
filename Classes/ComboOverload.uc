//=============================================================================
// ComboOverload.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboOverload extends RPGCombo;

var float VehicleFireSpeedModifier;

var FX_ComboOverload FX;
var FX_ComboOverload_FP FX_FP;

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboOverload', P,, P.Location);
    FX_FP = Spawn(class'FX_ComboOverload_FP', P,, P.Location);
}

function DestroyEffects(Pawn P)
{
    if(FX != None)
        FX.ClientKill();
    if(FX_FP != None)
        FX_FP.ClientKill();
}

function StartEffect(xPawn P)
{
    local int i;

    Super.StartEffect(P);

    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(P.Controller);

    if(P.Weapon != None)
        P.Weapon.StartBerserk();

    P.bBerserk = true;

    if(RPRI != None)
    {
        if(P.Weapon != None)
        {
            for(i = 0; i < RPRI.Abilities.Length; i++)
                if(RPRI.Abilities[i].bAllowed)
                    RPRI.Abilities[i].ModifyWeapon(P.Weapon);
        }

        for(i = 0; i < RPRI.Sentinels.Length; i++)
            if(Vehicle(RPRI.Sentinels[i].Pawn) != None)
                ModifyVehicle(Vehicle(RPRI.Sentinels[i].Pawn));
    }
}

function StopEffect(xPawn P)
{
    local int i;
    local Inventory Inv;

    Super.StopEffect(P);

    for(Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
        if(Weapon(Inv) != None)
            Weapon(Inv).StopBerserk();

    P.bBerserk = false;

    if(RPRI != None)
    {
        if(P.Weapon != None)
        {
            for(i = 0; i < RPRI.Abilities.Length; i++)
                if(RPRI.Abilities[i].bAllowed)
                    RPRI.Abilities[i].ModifyWeapon(P.Weapon);
        }

        for(i = 0; i < RPRI.Sentinels.Length; i++)
            if(Vehicle(RPRI.Sentinels[i].Pawn) != None)
                UnModifyVehicle(Vehicle(RPRI.Sentinels[i].Pawn));
    }
}

function ModifyVehicle(Vehicle V)
{
    class'Util'.static.SetVehicleOverlay(V, Shader'OverloadShader', -1, true);

    if(RPGDefenseSentinelController(V.Controller) != None)
        RPGDefenseSentinelController(V.Controller).TimeBetweenShots *= (1 - VehicleFireSpeedModifier);
    //TODO lightning sentinels?
    else
        class'Util'.static.AdjustVehicleFireRate(V, 1.f + VehicleFireSpeedModifier);
}

function UnModifyVehicle(Vehicle V)
{
    class'Util'.static.SetVehicleOverlay(V, Shader'OverloadShader', 0, true);

    if(RPGDefenseSentinelController(V.Controller) != None)
        RPGDefenseSentinelController(V.Controller).TimeBetweenShots /= (1 - VehicleFireSpeedModifier);
    //TODO lightning sentinels?
    else
        class'Util'.static.AdjustVehicleFireRate(V, 1 / (1 + VehicleFireSpeedModifier));
}

defaultproperties
{
    VehicleFireSpeedModifier=0.75
    ExecMessage="Overload!"
    ComboAnnouncementName="ComboOverload"
    Duration=20.000000
    keys(0)=2
    keys(1)=2
    keys(2)=1
    keys(3)=1
}
