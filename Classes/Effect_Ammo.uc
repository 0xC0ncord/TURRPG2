//=============================================================================
// Effect_Ammo.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Ammo extends RPGInstantEffect;

var int AmmoAmount;

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    if(Other.Controller != None)
    {
        if(!Other.Controller.SameTeamAs(Causer))
            return false;
        if(Other.Weapon == None || class'Util'.static.InArray(Other.Weapon.AmmoClass[0], class'MutTURRPG'.default.SuperAmmoClasses) >= 0)
            return false;
    }
    else if(Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.Team != None)
    {
        if(Causer == None || Causer.GetTeamNum() != Other.PlayerReplicationInfo.Team.TeamIndex)
            return false;
    }

    return Super.CanBeApplied(Other, Causer, Duration, Modifier);
}

function bool ShouldDisplayEffect()
{
    return Vehicle(Instigator) == None;
}

function DoEffect()
{
    local int AmmoGiven;
    local int CurAmmo;
    local int MaxAmmo;

    if(Instigator.Weapon != None)
    {
        CurAmmo = Instigator.Weapon.AmmoAmount(0);
        MaxAmmo = Instigator.Weapon.AmmoClass[0].default.MaxAmmo;
        if(CurAmmo + AmmoGiven > MaxAmmo)
            AmmoGiven = MaxAmmo - CurAmmo;
        Instigator.Weapon.AddAmmo(AmmoGiven,0);
    }
}

defaultproperties
{
     AmmoAmount=10
     bHarmful=False
     EffectSound=Sound'PickupSounds.AssaultAmmoPickup'
     EffectMessageClass=Class'EffectMessage_Ammo'
}
