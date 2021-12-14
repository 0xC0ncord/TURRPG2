//=============================================================================
// RPGComboDefensive.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//fix for not granting shields when health is above normal max
class RPGComboDefensive extends RPGCombo;

var xEmitter Effect;
var RPGPlayerReplicationInfo RPRI;

function CreateEffects(Pawn P)
{
    if(P.Role == ROLE_Authority)
        Effect = Spawn(class'RegenCrosses', P,, P.Location, P.Rotation);
}

function DestroyEffects(Pawn P)
{
    if (Effect != None)
        Effect.Destroy();
}

function StartEffect(xPawn P)
{
    Super.StartEffect(P);
    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(P.Controller);
    SetTimer(0.9, true);
    Timer();
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

    if(P.Controller.PlayerReplicationInfo != None && P.Controller.PlayerReplicationInfo.HasFlag != None)
        DeltaTime *= 2;

    if(RPRI!=None)
        RPRI.DrainAdrenaline(AdrenalineCost * DeltaTime / Duration, Self);
    else
        P.Controller.Adrenaline -= AdrenalineCost * DeltaTime / Duration;
    if (P.Controller.Adrenaline <= 0.0)
    {
        P.Controller.Adrenaline = 0.0;
        Destroy();
    }
}

function Timer()
{
    if(Owner.Role == ROLE_Authority)
    {
        Pawn(Owner).GiveHealth(5, Pawn(Owner).SuperHealthMax);
        if (Pawn(Owner).Health >= Pawn(Owner).SuperHealthMax)
            Pawn(Owner).AddShieldStrength(5);
    }
}

defaultproperties
{
     ExecMessage="Booster!"
     ComboAnnouncementName="Booster"
     keys(0)=2
     keys(1)=2
     keys(2)=2
     keys(3)=2
}
