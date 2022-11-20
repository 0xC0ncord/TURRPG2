//=============================================================================
// Effect_MoteAmmo.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_MoteAmmo extends Effect_Mote;

var int MinRegenPerLevel;

var MutTURRPG RPGMut;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if(Role == ROLE_Authority)
        RPGMut = class'MutTURRPG'.static.Instance(Level);
}

state Activated
{
    function Timer()
    {
        local Inventory Inv;
        local Weapon W;
        local Ammunition Ammo;

        Super.Timer();

        //copied from Ability_AmmoRegen
        for(Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            W = Weapon(Inv);
            if(W != None)
            {
                if(W.bNoAmmoInstances && W.AmmoClass[0] != None && !RPGMut.IsSuperWeaponAmmo(W.AmmoClass[0]))
                {
                    W.AddAmmo(GetRegenAmountFor(W.AmmoClass[0]), 0);
                    if(W.AmmoClass[0] != W.AmmoClass[1] && W.AmmoClass[1] != None)
                        W.AddAmmo(GetRegenAmountFor(W.AmmoClass[1]), 1);
                }
            }
            else
            {
                Ammo = Ammunition(Inv);
                if(Ammo != None && !RPGMut.IsSuperWeaponAmmo(Ammo.Class))
                    Ammo.AddAmmo(GetRegenAmountFor(Ammo.class));
            }
        }
    }
}

function int GetRegenAmountFor(class<Ammunition> AmmoClass)
{
    return Max(MinRegenPerLevel * (Modifier * 10), int(
        (Modifier * 10) * float(Stacks) * float(AmmoClass.default.MaxAmmo)));
}

defaultproperties
{
    MinRegenPerLevel=1
    EffectClass=class'FX_MoteActive_Green'
    DoubleEffectClass=class'FX_MoteActive_Green_Double'
    TripleEffectClass=class'FX_MoteActive_Green_Triple'
    StatusIconClass=class'StatusIcon_MoteAmmo'
    DoubleStatusIconClass=class'StatusIcon_MoteAmmo_Double'
    TripleStatusIconClass=class'StatusIcon_MoteAmmo_Triple'
    EffectMessageClass=class'EffectMessage_Ammo'
}
