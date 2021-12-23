//=============================================================================
// ComboIronSpirit.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboIronSpirit extends RPGCombo;

var RPGPlayerReplicationInfo RPRI;

var FX_ComboIronSpirit FX;
var FX_ComboIronSpirit_FP FX_FP;

simulated function Tick(float DeltaTime)
{
    local Pawn P;

    P = Pawn(Owner);

    if (P == None || P.Controller == None)
    {
        Destroy();
        return;
    }

    if (P.Controller.PlayerReplicationInfo != None && P.Controller.PlayerReplicationInfo.HasFlag != None)
        DeltaTime *= 2;
    if(RPRI != None)
        RPRI.DrainAdrenaline(AdrenalineCost * DeltaTime / Duration, Self);
    else
        P.Controller.Adrenaline -= AdrenalineCost * DeltaTime / Duration;
    if (P.Controller.Adrenaline <= 0.0)
    {
        P.Controller.Adrenaline = 0.0;
        Destroy();
    }
}

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboIronSpirit', P,, P.Location);
    FX_FP = Spawn(class'FX_ComboIronSpirit_FP', P,, P.Location);
}

function DestroyEffects(Pawn P)
{
    if(FX != None)
        FX.ClientKill();
    if(FX_FP != None)
        FX_FP.ClientKill();
}

defaultproperties
{
     ExecMessage="Iron Spirit!"
     Duration=20.000000
     ComboAnnouncementName="ComboIronSpirit"
     keys(0)=4
     keys(1)=4
     keys(2)=8
     keys(3)=8
}
