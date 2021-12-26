//=============================================================================
// RPGCombo.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGCombo extends Combo;

var bool bFlagSensitive; // drain more adrenaline if owner is carrying a flag

var RPGPlayerReplicationInfo RPRI;

function CreateEffects(Pawn P);
function DestroyEffects(Pawn P);

function Destroyed()
{
    local xPawn P;
    local int i;

    P = xPawn(Owner);

    if (P != None)
    {
        StopEffect(P);

        if(RPGPawn(Owner) != None)
        {
            i = class'Util'.static.InArray(Self, RPGPawn(Owner).ActiveCombos);
            RPGPawn(Owner).ActiveCombos.Remove(i, 1);
            if(P.CurrentCombo == self)
            {
                if(RPGPawn(Owner).ActiveCombos.Length > 0)
                    P.CurrentCombo = RPGPawn(Owner).ActiveCombos[RPGPawn(Owner).ActiveCombos.Length - 1];
                else
                    P.CurrentCombo = None;
            }
        }
        else if (P.CurrentCombo == self)
            P.CurrentCombo = None;
    }
}

function StartEffect(xPawn P)
{
    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(P.Controller);

    CreateEffects(P);
}

function StopEffect(xPawn P)
{
    DestroyEffects(P);
}

simulated function Tick(float DeltaTime)
{
    local Pawn P;

    P = Pawn(Owner);

    if(P == None || P.Controller == None)
    {
        Destroy();
        return;
    }

    if(
        bFlagSensitive
        && P.Controller.PlayerReplicationInfo != None
        && P.Controller.PlayerReplicationInfo.HasFlag != None
    )
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

defaultproperties
{
    bFlagSensitive=True
}
