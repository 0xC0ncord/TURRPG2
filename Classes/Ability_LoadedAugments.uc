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
    GrantAugments(7)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Knockback',Amount=5)
    GrantAugments(8)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_PullForward',Amount=5)
    GrantAugments(9)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Freeze',Amount=5)
    GrantAugments(10)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_NullEntropy',Amount=5)
    GrantAugments(11)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Force',Amount=5)
    GrantAugments(12)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Piercing',Amount=5)
    GrantAugments(13)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Penetrating',Amount=5)
    GrantAugments(14)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Protection',Amount=5)
    GrantAugments(15)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Lucky',Amount=5)
    GrantAugments(16)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Poison',Amount=5)
    GrantAugments(17)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Resupply',Amount=5)
    GrantAugments(18)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Retaliation',Amount=5)
    GrantAugments(19)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Speed',Amount=5)
    GrantAugments(20)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Sturdy',Amount=5)
    GrantAugments(21)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Vorpal',Amount=5)
    GrantAugments(22)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Explosive',Amount=5)
    GrantAugments(23)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Regen',Amount=5)
    GrantAugments(24)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_RockShield',Amount=5)
    GrantAugments(25)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Vacuuming',Amount=5)
    GrantAugments(26)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Shimmering',Amount=5)
    GrantAugments(27)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_Bombing',Amount=5)
    GrantAugments(28)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_StoredPower',Amount=5)
    GrantAugments(29)=(AbilityLevel=2,AugmentClass=Class'ArtificerAugment_SlowMotion',Amount=5)
    AbilityName="Loaded Augments"
    Description="Grants you augments for use in the Artificer's Workbench. Each level of this ability will grant you more powerful augments."
    StartingCost=4
    CostAddPerLevel=4
    MaxLevel=3
    Category=Class'AbilityCategory_Weapons'
}
