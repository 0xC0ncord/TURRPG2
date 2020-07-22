//=============================================================================
// StatusIcon_VehicleEject.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_VehicleEject extends RPGStatusIcon;

var Ability_VehicleEject EjectorSeat;

function Tick(float dt)
{
    EjectorSeat = Ability_VehicleEject(RPRI.GetAbility(class'Ability_VehicleEject'));
    bShouldTick = (EjectorSeat == None);
}

function bool IsVisible()
{
    return (
        EjectorSeat != None &&
        EjectorSeat.AbilityLevel >= 0 &&
        EjectorSeat.NextVehicleTime > EjectorSeat.Level.TimeSeconds
    );
}

function string GetText()
{
    return string(1 + int(EjectorSeat.NextVehicleTime - EjectorSeat.Level.TimeSeconds));
}

defaultproperties
{
    IconMaterial=Texture'TURRPG2.StatusIcons.Eject'
    bShouldTick=True
}
