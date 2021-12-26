//=============================================================================
// ComboSiphon.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboSiphon extends RPGCombo;

var ComboSiphonOrb Orb;

var FX_ComboSiphon FX;

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboSiphon', P,, P.Location);
}

function DestroyEffects(Pawn P)
{
    if(FX != None)
        FX.ClientKill();
}

function StartEffect(xPawn P)
{
    Super.StartEffect(P);

    Orb = P.Spawn(class'ComboSiphonOrb', P,, P.Location);
}

function StopEffect(xPawn P)
{
    Super.StopEffect(P);

    if(Orb != None)
        Orb.Destroy();
}

defaultproperties
{
    ExecMessage="Siphon!"
    ComboAnnouncementName="ComboSiphon"
    keys(0)=4
    keys(1)=4
    keys(2)=2
    keys(3)=2
}
