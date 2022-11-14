//=============================================================================
// ArtifactBase_ArtificerCharm.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactBase_ArtificerCharm extends ArtifactBase_WeaponMaker
    abstract
    HideDropDown;

var AbilityBase_ArtificerCharm Ability;
var class<Weapon> DesiredWeaponClass;
var bool bWantsAutoApply;

replication
{
    reliable if(Role < ROLE_Authority)
        ServerAutoApplyWeapon;
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
        DoModifyWeapon(ModifiedWeapon);

        Msg(MSG_Broken);

        if(PlayerController(Instigator.Controller) != None)
            PlayerController(Instigator.Controller).ClientPlaySound(BrokenSound);

        RemoveOne();

        return true;
    }
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(InstigatorRPRI != None && InstigatorRPRI.bClientSetup)
    {
        PRINTD(InstigatorRPRI);
        SetupDesiredWeapon();
        if(DesiredWeaponClass == None || TryAutoApplyWeapon())
        {
            Disable('Tick');
            return;
        }
    }
    bWantsAutoApply = true;
}

simulated function SetupDesiredWeapon()
{
    switch(Class)
    {
        case class'Artifact_ArtificerCharmAlpha':
            DesiredWeaponClass = InstigatorRPRI.ArtificerAutoApplyWeaponAlpha;
            break;
        case class'Artifact_ArtificerCharmBeta':
            DesiredWeaponClass = InstigatorRPRI.ArtificerAutoApplyWeaponBeta;
            break;
        case class'Artifact_ArtificerCharmGamma':
            DesiredWeaponClass = InstigatorRPRI.ArtificerAutoApplyWeaponGamma;
            break;
    }
}

simulated function bool TryAutoApplyWeapon()
{
    local Inventory Inv;

    PRINTD("Trying to auto-apply on" @ DesiredWeaponClass);

    for(Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if(Inv.Class == DesiredWeaponClass)
        {
            PRINTD("Applying on" @ Inv);
            ServerAutoApplyWeapon(Weapon(Inv));
            return true;
        }
    }
    return false;
}

simulated function Tick(float dt)
{
    if(Level.NetMode == NM_DedicatedServer)
        return;

    if(bWantsAutoApply)
    {
        if(DesiredWeaponClass == None)
            SetupDesiredWeapon();
        TryAutoApplyWeapon();
    }
    bWantsAutoApply = false; //only try again for 1 tick
}

function ServerAutoApplyWeapon(Weapon Weapon)
{
    PRINTD("Attempting to auto-apply on" @ Weapon);

    if(Weapon != None)
        ForcedWeapon = Weapon;
    else
        return;

    PRINTD("Activating!");
    Activate();

    ForcedWeapon = None;
}

function DoModifyWeapon(Weapon W)
{
    local WeaponModifier_Artificer WM;

    if(ModifiedWeapon.bNoAmmoInstances)
        Ability.OldAmmoCount = ModifiedWeapon.AmmoCharge[0];
    else
        Ability.OldAmmoCount = class'DummyWeaponHack'.static.GetAmmo(ModifiedWeapon, 0).AmmoAmount;

    WM = WeaponModifier_Artificer(ModifierClass.static.Modify(ModifiedWeapon, Ability.AbilityLevel, true));
    switch(Class)
    {
        case class'Artifact_ArtificerCharmAlpha':
            WM.InitAugments(InstigatorRPRI.ArtificerAugmentsAlpha);
            break;
        case class'Artifact_ArtificerCharmBeta':
            WM.InitAugments(InstigatorRPRI.ArtificerAugmentsBeta);
            break;
        case class'Artifact_ArtificerCharmGamma':
            WM.InitAugments(InstigatorRPRI.ArtificerAugmentsGamma);
            break;
    }

    Ability.WeaponModifier = WM;
}

defaultproperties
{
    MsgDuplicate="This weapon has already been sealed with another Artificer's Charm."
    ModifierClass=Class'WeaponModifier_Artificer'
    CostPerSec=0
    HudColor=(B=255,G=192,R=128)
    ArtifactID="ArtificerCharm"
    bCanBeTossed=False
    Description="Seals a weapon with the chosen augments."
    IconMaterial=Texture'PowerCharmIcon'
    ItemName="Artificer's Charm"
}
