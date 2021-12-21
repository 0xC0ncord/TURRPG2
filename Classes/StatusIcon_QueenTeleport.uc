//=============================================================================
// StatusIcon_QueenTeleport.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_QueenTeleport extends RPGStatusIcon;

var MorphMonster_Queen Queen;

function bool IsVisible()
{
    return (Queen != None && Queen.NextTeleportTime > 0);
}

function Initialize()
{
    if((RPRI.Controller == None || MorphMonster_Queen(RPRI.Controller.Pawn) == None) && RPRI != None)
    {
        RPRI.ClientRemoveStatusIcon(Class);
        return;
    }

    Queen = MorphMonster_Queen(RPRI.Controller.Pawn);
}

function Tick(float dt)
{
    if(RPRI.Controller == None || Queen==None || Queen.Health <= 0)
        RPRI.ClientRemoveStatusIcon(Class);
}

function string GetText()
{
    if(Queen == None)
        return "";
    if(Queen.Level.NetMode == NM_Client)
        return class'Util'.static.FormatTime(Queen.NextTeleportTime);
    else
        return class'Util'.static.FormatTime(Queen.NextTeleportTime - Queen.Level.TimeSeconds);
}

defaultproperties
{
     IconMaterial=Texture'QueenTeleportIcon'
}
