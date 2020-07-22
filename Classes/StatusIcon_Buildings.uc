//=============================================================================
// StatusIcon_Buildings.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_Buildings extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumBuildings > 0);
}

function string GetText()
{
    return RPRI.NumBuildings $ "/" $ RPRI.MaxBuildings;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.BuildingIcon'
}
