//=============================================================================
// StatusIcon_Vehicles.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_Vehicles extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumVehicles > 0);
}

function string GetText()
{
    return RPRI.NumVehicles $ "/" $ RPRI.MaxVehicles;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.VehicleIcon'
}
