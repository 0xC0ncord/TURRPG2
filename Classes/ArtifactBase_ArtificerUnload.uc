//=============================================================================
// ArtifactBase_ArtificerUnload.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactBase_ArtificerUnload extends ArtifactBase_DelayedUse
    abstract
    HideDropDown;

const MSG_Broken = 0x0100;
var localized string MsgBroken;
var() Sound BrokenSound;

var class<ArtifactBase_ArtificerCharm> ArtificerCharmClass;

var AbilityBase_ArtificerCharm Ability;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_Broken:
            return default.MsgBroken;

        default:
            return Super.GetMessageString(Msg, Value);
    }
}

function bool CanActivate()
{
    if(!Super.CanActivate() || Ability == None)
        return false;

    return true;
}

state Activated
{
    function bool DoEffect()
    {
        local ArtifactBase_ArtificerCharm Artifact;

        Artifact = ArtifactBase_ArtificerCharm(class'Util'.static.GiveInventory(Instigator, ArtificerCharmClass));
        if(Artifact != None)
            Artifact.Ability = Ability;

        Ability.WeaponModifier.static.RemoveModifier(Ability.WeaponModifier.Weapon);

        Msg(MSG_Broken);

        if(PlayerController(Instigator.Controller) != None)
            PlayerController(Instigator.Controller).ClientPlaySound(BrokenSound);

        RemoveOne();

        return true;
    }
}

defaultproperties
{
    MsgBroken="The weapon's augments have been unsealed."
    bAllowInVehicle=False
    CostPerSec=0
    HudColor=(B=255,G=192,R=128)
    ArtifactID="ArtificerUnload"
    bCanBeTossed=False
    Description="Unseals a weapon's augments and retrieves its Artificer's Charm."
    IconMaterial=Texture'PowerCharmIcon'
    ItemName="Artificer's Unsealer"
}

