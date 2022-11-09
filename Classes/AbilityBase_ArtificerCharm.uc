//=============================================================================
// AbilityBase_ArtificerCharm.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class AbilityBase_ArtificerCharm extends RPGAbility
    abstract;

var WeaponModifier_Artificer WeaponModifier; //to prevent granting multiple charms by upgrading this ability
var ArtifactBase_ArtificerCharm Artifact;

var int OldAmmoCount; //TODO old amount of ammo a weapon had before it was sealed
                      //to prevent gaining infinite ammo from sealing/unsealing

replication
{
    reliable if(Role == ROLE_Authority)
        WeaponModifier;
}

function ModifyPawn(Pawn Other)
{
    local int x, i;
    local Ability_Denial Denial;
    local class<ArtifactBase_ArtificerCharm> AClass;

    Instigator = Other;

    if(StatusIconClass != None)
        RPRI.ClientCreateStatusIcon(StatusIconClass);

    for(x = 0; x < GrantItem.Length; x++)
    {
        if(AbilityLevel >= GrantItem[x].Level)
        {
            AClass = class<ArtifactBase_ArtificerCharm>(GrantItem[x].InventoryClass);
            if(AClass == None)
            {
                class'Util'.static.GiveInventory(Other, GrantItem[x].InventoryClass);
                continue;
            }

            //ability was just upgraded
            if(bJustBought && AbilityLevel > 1)
            {
                //if they have denial, don't grant another charm if a weapon is going to be restored
                Denial = Ability_Denial(RPRI.GetOwnedAbility(class'Ability_Denial'));
                if(Denial != None)
                {
                    for(i = 0; i < Denial.StoredWeapons.Length; i++)
                    {
                        if(Denial.StoredWeapons[i].ModifierClass == AClass.default.ModifierClass)
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
                    Artifact = ArtifactBase_ArtificerCharm(Other.FindInventoryType(GrantItem[x].InventoryClass));

                    //artifact uses ability's level instead of tracking it, so we only care if it was used
                    if(Artifact == None && WeaponModifier != None)
                        WeaponModifier.SetModifier(AbilityLevel, true);
                }
            }
            else //ability was just bought or player just spawned
            {
                Artifact = ArtifactBase_ArtificerCharm(class'Util'.static.GiveInventory(Other, GrantItem[x].InventoryClass));
                if(Artifact != None)
                    Artifact.Ability = Self;
            }
        }
    }
}

defaultproperties
{
    GrantItem(0)=(Level=1,InventoryClass=Class'ArtifactBase_ArtificerCharm')
    StartingCost=5
    CostAddPerLevel=1
    MaxLevel=10
    AbilityName="Artificer Charm"
    Description="Allows you to seal augments onto weapons using an artificer charm. Every level of this ability will increase the total number of slots available for augments on the artificer charm given by this ability."
    Category=Class'AbilityCategory_Weapons'
}
