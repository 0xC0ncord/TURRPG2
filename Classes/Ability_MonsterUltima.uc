//=============================================================================
// Ability_MonsterUltima.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MonsterUltima extends RPGAbility;

var config float BaseDelay; //should at least be equal to the max level

var float TryRadiusMin, TryRadiusMax; //if spawning a charger fails, try randomly around the monster

function bool PreventDeath(
    Pawn Killed,
    Controller Killer,
    class<DamageType> DamageType,
    vector HitLocation,
    bool bAlreadyPrevented
)
{
    local Blast_Ultima UC;
    local int Tries;
    local vector TryLocation;

    if(bAlreadyPrevented)
        return false;

    if(DamageType == class'Suicided')
        return false;

    if(FriendlyMonsterController(Killed.Controller) == None)
        return false;

    if(Killed.Location.Z > Killed.Region.Zone.KillZ)
    {
        if(SpawnCharger(Killed.Location) == None)
        {
            //Location is blocked by something, try somewhere else
            for(Tries = 0; Tries < 25; Tries++)
            {
                TryLocation = Killed.Location +
                    VRand() * (TryRadiusMin + FRand() * (TryRadiusMax - TryRadiusMin));

                UC = SpawnCharger(TryLocation);
                if(UC != None)
                    break;
            }

            if(UC == None)
                Warn("Failed to spawn Ultima charger for" @ Killed.GetHumanReadableName());
        }
    }

    return false;
}

function Blast_Ultima SpawnCharger(vector ChargerLocation)
{
    local Blast_Ultima UC;

    UC = Spawn(class'Blast_MonsterUltima', RPRI.Controller,, ChargerLocation);
    if(UC != None)
    {
        UC.SetChargeTime(FMax(float(MaxLevel), BaseDelay) - float(AbilityLevel));
        UC.Damage = UC.Damage + (UC.Damage * BonusPerLevel * AbilityLevel);
    }
    return UC;
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    RequiredAbilities(0)=(AbilityClass=Class'Ability_MonsterDamageBonus',Level=10)
    BaseDelay=5.000000
    TryRadiusMin=32.000000
    TryRadiusMax=48.000000
    BonusPerLevel=0.10
    MaxLevel=5
    bUseLevelCost=True
    LevelCost(0)=60
    LevelCost(1)=10
    LevelCost(2)=10
    LevelCost(3)=10
    LevelCost(4)=10
    AbilityName="Monster Ultima"
    Description="Whenever one of your summoned monsters is killed, it will create a miniature Ultima. For each level of this ability, the Ultima's damage will be increased by $1.|Level 1 waits 4 seconds after the monster died, and each higher level waits 1 second less."
    Category=Class'AbilityCategory_Monsters'
}
