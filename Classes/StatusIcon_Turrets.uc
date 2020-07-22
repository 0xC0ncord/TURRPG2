//=============================================================================
// StatusIcon_Turrets.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_Turrets extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumTurrets > 0);
}

function string GetText()
{
    return RPRI.NumTurrets $ "/" $ RPRI.MaxTurrets;
}

defaultproperties
{
    IconMaterial=Texture'TURRPG2.StatusIcons.TurretIcon'
}
