//=============================================================================
// ComboHeal.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboHeal extends RPGCombo;

var int HealAmount;

function CreateEffects(Pawn P)
{
    if(P.Role == ROLE_Authority)
        Spawn(class'FX_ComboHeal', P,, P.Location, P.Rotation);
}

function StartEffect(xPawn P)
{
    local RPGPlayerReplicationInfo RPRI;
    local int OldHealth;

    Super.StartEffect(P);

    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(P.Controller);

    if(P.Role == ROLE_Authority)
    {
        OldHealth = P.Health;
        P.GiveHealth(HealAmount, P.SuperHealthMax);
        if(OldHealth + HealAmount > P.Health)
            P.AddShieldStrength(OldHealth + HealAmount - P.SuperHealthMax);

        if(RPRI != None)
            RPRI.DrainAdrenaline(AdrenalineCost, Self);
        else
            P.Controller.Adrenaline -= AdrenalineCost;
        Destroy();
    }
}

defaultproperties
{
    HealAmount=100
    ExecMessage="Heal!"
    ComboAnnouncementName="Heal"
    keys(0)=2
    keys(1)=2
    keys(2)=2
    keys(3)=2
}
