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

var class<ArtifactBase_ArtificerUnload> UnloadArtifactClass;

var AbilityBase_ArtificerCharm Ability;
var class<Weapon> DesiredWeaponClass;
var bool bClientTryAutoApply;
var bool bWantsAutoApply;
var float GiveUpTime;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        bClientTryAutoApply;
    reliable if(Role < ROLE_Authority)
        ServerAutoApplyWeapon;
}

function bool CanActivate()
{
    if(!Super.CanActivate() || Ability == None)
        return false;

    //don't allow removing an existing artificer modifier
    if(class'WeaponModifier_Artificer'.static.GetFor(ModifiedWeapon) != None)
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

    if(!Instigator.IsLocallyControlled())
        return;

    CheckAutoApply();
}

simulated function CheckAutoApply()
{
    if(!bClientTryAutoApply)
        return;

    if(InstigatorRPRI != None && InstigatorRPRI.bClientSetup)
    {
        SetupDesiredWeapon();
        if(DesiredWeaponClass == None || TryAutoApplyWeapon())
            return;
    }
    bWantsAutoApply = true;
    GiveUpTime = Level.TimeSeconds + 5.0;
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
    local int Count;

    for(Inv = Instigator.Inventory; Inv != None && Count++ < 1000; Inv = Inv.Inventory)
    {
        if(Inv.Class == DesiredWeaponClass)
        {
            ServerAutoApplyWeapon(Weapon(Inv));
            return true;
        }
    }
    return false;
}

simulated function Tick(float dt)
{
    if(!Instigator.IsLocallyControlled())
        return;

    if(bWantsAutoApply)
    {
        if(DesiredWeaponClass == None)
            SetupDesiredWeapon();
        if(TryAutoApplyWeapon())
            bWantsAutoApply = false;
    }

    if(Level.TimeSeconds <= GiveUpTime)
        bWantsAutoApply = false; //done trying
}

function ServerAutoApplyWeapon(Weapon Weapon)
{
    if(Weapon != None)
        ForcedWeapon = Weapon;
    else
        return;

    Activate();

    ForcedWeapon = None;
}

function DoModifyWeapon(Weapon W)
{
    local WeaponModifier_Artificer WM;
    local ArtifactBase_ArtificerUnload Artifact;

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

    Artifact = ArtifactBase_ArtificerUnload(class'Util'.static.GiveInventory(Instigator, UnloadArtifactClass));
    if(Artifact != None)
        Artifact.Ability = Ability;
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
