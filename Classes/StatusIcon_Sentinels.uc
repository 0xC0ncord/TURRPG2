//=============================================================================
// StatusIcon_Sentinels.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_Sentinels extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumSentinels > 0);
}

function string GetText()
{
    return RPRI.NumSentinels $ "/" $ RPRI.MaxSentinels;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.SentinelIcon'
}
