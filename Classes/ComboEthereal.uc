//=============================================================================
// ComboEthereal.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboEthereal extends RPGCombo;

var bool bOldBlockZeroExtentTraces;
var bool bOldBlockNonZeroExtentTraces;
var bool bOldProjTarget;

var FX_ComboEthereal FX;
var FX_ComboEthereal_FP FX_FP;

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboEthereal', P,, P.Location);
    FX_FP = Spawn(class'FX_ComboEthereal_FP', P,, P.Location);
    class'Sync_OverlayMaterial'.static.Sync(P, Shader'EtherealShader', -1, true);
}

function DestroyEffects(Pawn P)
{
    if(FX != None)
        FX.ClientKill();
    if(FX_FP != None)
        FX_FP.ClientKill();
    class'Sync_OverlayMaterial'.static.Sync(P, None, 0, true);
}

function StartEffect(xPawn P)
{
    Super.StartEffect(P);

    P.SetCollision(false, false, false);

    bOldBlockZeroExtentTraces = P.bBlockZeroExtentTraces;
    bOldBlockNonZeroExtentTraces = P.bBlockNonZeroExtentTraces;
    bOldProjTarget = P.bProjTarget;
    P.bBlockZeroExtentTraces = false;
    P.bBlockNonZeroExtentTraces = false;
    P.bProjTarget = false;
}

function StopEffect(xPawn P)
{
    Super.StopEffect(P);

    P.SetCollision(true, true, true);

    P.bBlockZeroExtentTraces = bOldBlockZeroExtentTraces;
    P.bProjTarget = bOldProjTarget;

    if(bOldBlockNonZeroExtentTraces)
        Spawn(class'ComboEtherealWatcher', P);
}

defaultproperties
{
    Duration=15.000000
    ExecMessage="Ethereal!"
    ComboAnnouncementName="ComboEthereal"
    keys(0)=8
    keys(1)=8
    keys(2)=4
    keys(3)=4
}
