//=============================================================================
// AbilityBase_ArtificerCharm.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class AbilityBase_ArtificerCharm extends RPGAbility
    abstract;

var class<ArtifactBase_ArtificerCharm> ArtificerCharmClass;

var WeaponModifier_Artificer WeaponModifier; //to prevent granting multiple charms by upgrading this ability
var ArtifactBase_ArtificerCharm Artifact;

var int OldAmmoCount; //TODO old amount of ammo a weapon had before it was sealed
                      //to prevent gaining infinite ammo from sealing/unsealing

var class<Weapon> AutoApplyWeaponClass; //weapon class to auto-apply on

replication
{
    reliable if(Role == ROLE_Authority)
        WeaponModifier;
}

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    GrantArtificerCharm(Other);
}

function ModifyGrantedWeapon(Weapon Weapon, RPGWeaponModifier WM, optional Object Source)
{
    if(Weapon.Class == AutoApplyWeaponClass)
    {
        //make sure this is legal
        if(!class'WeaponModifier_Artificer'.static.AllowedFor(Weapon.Class, Weapon.Instigator)
            || Weapon.Class == class'BallLauncher'
            || Weapon.Class == class'TransLauncher'
        )
        {
            //give them an artifact if they dont have one and be done.
            if(Weapon.Instigator.FindInventoryType(ArtificerCharmClass) != None)
                return; //wtf?

            Artifact = ArtifactBase_ArtificerCharm(class'Util'.static.GiveInventory(Weapon.Instigator, ArtificerCharmClass));
            if(Artifact != None)
                Artifact.Ability = Self;
        }
        else
        {
            //mostly copied from ArtifactBase_ArtificerCharm::Activated::DoEffect
            if(Weapon.bNoAmmoInstances)
                OldAmmoCount = Weapon.AmmoCharge[0];
            else
                OldAmmoCount = class'DummyWeaponHack'.static.GetAmmo(Weapon, 0).AmmoAmount;

            WeaponModifier = WeaponModifier_Artificer(class'WeaponModifier_Artificer'.static.Modify(Weapon, AbilityLevel, true));
            switch(Class)
            {
                case class'Ability_ArtificerCharmAlpha':
                    WeaponModifier.InitAugments(RPRI.ArtificerAugmentsAlpha);
                    break;
                case class'Ability_ArtificerCharmBeta':
                    WeaponModifier.InitAugments(RPRI.ArtificerAugmentsBeta);
                    break;
                case class'Ability_ArtificerCharmGamma':
                    WeaponModifier.InitAugments(RPRI.ArtificerAugmentsGamma);
                    break;
            }

            WeaponModifier.bCanThrow = false;
        }
    }
}

function GrantArtificerCharm(Pawn Other)
{
    local int i;
    local Ability_Denial Denial;

    //ability was just upgraded
    if(bJustBought && AbilityLevel > 1)
    {
        //if they have denial, don't grant another charm if a weapon is going to be restored
        Denial = Ability_Denial(RPRI.GetOwnedAbility(class'Ability_Denial'));
        if(Denial != None)
        {
            for(i = 0; i < Denial.StoredWeapons.Length; i++)
            {
                if(Denial.StoredWeapons[i].ModifierClass == ArtificerCharmClass.default.ModifierClass)
                {
                    //ability was upgraded, let's upgrade this modifier
                    Denial.StoredWeapons[i].Modifier = AbilityLevel;
                    i = -1;
                    break;
                }
            }
        }

        //we should only get here if the player is alive
        if(i != -1)
        {
            //just upgrade the artifact or weapon modifier
            Artifact = ArtifactBase_ArtificerCharm(Other.FindInventoryType(ArtificerCharmClass));

            //artifact uses ability's level instead of tracking it, so we only care if it was used
            if(Artifact == None && WeaponModifier != None)
                WeaponModifier.SetModifier(AbilityLevel, true);
        }
    }
    else if(AutoApplyWeaponClass == None) //ability was just bought or player just spawned
    {
        Artifact = ArtifactBase_ArtificerCharm(class'Util'.static.GiveInventory(Other, ArtificerCharmClass));
        if(Artifact != None)
            Artifact.Ability = Self;
    }
}

defaultproperties
{
    StartingCost=5
    CostAddPerLevel=1
    MaxLevel=10
    AbilityName="Artificer Charm"
    Description="Allows you to seal augments onto weapons using an artificer charm. Every level of this ability will increase the total number of slots available for augments on the artificer charm given by this ability."
    Category=Class'AbilityCategory_Weapons'
}
