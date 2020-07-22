//=============================================================================
// StatusIcon_Utilities.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_Utilities extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumUtilities > 0);
}

function string GetText()
{
    return RPRI.NumUtilities $ "/" $ RPRI.MaxUtilities;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.UtilityIcon'
}
