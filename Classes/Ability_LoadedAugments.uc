//=============================================================================
// Ability_LoadedAugments.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_LoadedAugments extends RPGAbility;

struct AugmentStruct
{
    var() int AbilityLevel;
    var() class<ArtificerAugmentBase> AugmentClass;
    var() int Amount;
};
var() array<AugmentStruct> GrantAugments;

struct GrantedAugmentStruct
{
    var() class<ArtificerAugmentBase> AugmentClass;
    var() int Amount;
};
var array<GrantedAugmentStruct> GrantedAugments;

replication
{
    reliable if(Role == ROLE_Authority)
        CalculateGrantedAugments;
}

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    CalculateGrantedAugments();
}

simulated function CalculateGrantedAugments()
{
    local int i, x;

    for(i = 0; i < GrantAugments.Length; i++)
    {
        if(AbilityLevel < GrantAugments[i].AbilityLevel)
            continue;

        for(x = 0; x < GrantedAugments.Length; x++)
        {
            if(GrantAugments[i].AugmentClass == GrantedAugments[x].AugmentClass)
            {
                GrantedAugments[x].Amount += GrantAugments[i].Amount;
                x = -1;
                break;
            }
        }
        if(x != -1)
        {
            x = GrantedAugments.Length;
            GrantedAugments.Length = x + 1;
            GrantedAugments[x].AugmentClass = GrantAugments[i].AugmentClass;
            GrantedAugments[x].Amount = GrantAugments[i].Amount;
        }
    }
}

defaultproperties
{
    GrantAugments(0)=(AbilityLevel=1,AugmentClass=Class'ArtificerAugment_Energy',Amount=1)
    GrantAugments(1)=(AbilityLevel=1,AugmentClass=Class'ArtificerAugment_Damage',Amount=1)
    GrantAugments(2)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Energy',Amount=2)
    GrantAugments(3)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Damage',Amount=2)
    GrantAugments(4)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Infinity',Amount=2)
    GrantAugments(5)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Flight',Amount=2)
    GrantAugments(6)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Spread',Amount=5)
    AbilityName="Loaded Augments"
    Description="Grants you augments for use in the Artificer's Workbench. Each level of this ability will grant you more powerful augments."
    StartingCost=4
    CostAddPerLevel=4
    MaxLevel=3
    Category=Class'AbilityCategory_Weapons'
}
