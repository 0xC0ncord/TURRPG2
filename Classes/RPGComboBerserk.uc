//=============================================================================
// RPGComboBerserk.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGComboBerserk extends RPGCombo;

var xEmitter Effect;

function CreateEffects(Pawn P)
{
    if (P.Role == ROLE_Authority)
        Effect = Spawn(class'OffensiveEffect', P,, P.Location, P.Rotation);
}

function DestroyEffects(Pawn P)
{
    if (Effect != None)
        Effect.Destroy();
}

function StartEffect(xPawn P)
{
    local int i;

    Super.StartEffect(P);

    if(P.Weapon != None)
        P.Weapon.StartBerserk();

    P.bBerserk = true;

    if(RPRI != None && P.Weapon!=None)
        for(i = 0; i < RPRI.Abilities.Length; i++)
            if(RPRI.Abilities[i].bAllowed)
                RPRI.Abilities[i].ModifyWeapon(P.Weapon);
}

function StopEffect(xPawn P)
{
    local int i;
    local Inventory Inv;

    Super.StopEffect(P);

    for(Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
        if(Weapon(Inv) != None)
            Weapon(Inv).StopBerserk();

    P.bBerserk = false;

    if(RPRI != None && P.Weapon != None)
        for(i = 0; i < RPRI.Abilities.Length; i++)
            if(RPRI.Abilities[i].bAllowed)
                RPRI.Abilities[i].ModifyWeapon(P.Weapon);
}

defaultproperties
{
    ExecMessage="Berserk!"
    ComboAnnouncementName="Berzerk"
    keys(0)=2
    keys(1)=2
    keys(2)=1
    keys(3)=1
}
