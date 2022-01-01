//=============================================================================
// ComboHolograph.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboHolograph extends RPGCombo;

var ComboHolographDummy Dummy;

function StartEffect(xPawn P)
{
    local Actor A;
    local vector HitLocation, HitNormal;

    A = Trace(HitLocation, HitNormal, P.Location - vect(0, 0, 512), P.Location);
    if((A != None && !A.bWorldGeometry && A != Level) || HitLocation == vect(0, 0, 0))
    {
        if(PlayerController(P.Controller) != None)
            PlayerController(P.Controller).ReceiveLocalizedMessage(class'LocalMessage_ComboHolographCancel');
        Destroy();
        return;
    }

    Super.StartEffect(P);

    Dummy = Spawn(class'ComboHolographDummy', Self,, HitLocation + vect(0, 0, 60));
}

function StopEffect(xPawn P)
{
    Super.StopEffect(P);

    if(Dummy != None)
        Dummy.Destroy();
}

defaultproperties
{
    bFlagSensitive=False
    ExecMessage="Holograph!"
    ComboAnnouncementName="Holograph"
    keys(0)=4
    keys(1)=4
    keys(2)=1
    keys(3)=1
}
