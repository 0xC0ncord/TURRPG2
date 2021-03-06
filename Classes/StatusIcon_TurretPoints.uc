//=============================================================================
// StatusIcon_TurretPoints.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_TurretPoints extends RPGStatusIcon;

function bool IsVisible()
{
    return true;
}

function string GetText()
{
    return RPRI.TurretPoints $ "/" $ RPRI.MaxTurretPoints;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.TurretPointsIcon'
}
