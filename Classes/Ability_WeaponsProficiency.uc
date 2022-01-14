//=============================================================================
// Ability_WeaponsProficiency.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_WeaponsProficiency extends RPGAbility;

var float MaxIncrease;

static function float GetNumKillsForWeapon(
    class<Weapon> WeaponClass,
    TeamPlayerReplicationInfo TPPI,
    int AbilityLevel
)
{
    local int i;

    if(TPPI == None)
        return 0;

    for(i = 0; i < TPPI.WeaponStatsArray.Length; i++)
    {
        if(TPPI.WeaponStatsArray[i].WeaponClass == WeaponClass)
        {
            return FMin(
                default.MaxIncrease,
                TPPI.WeaponStatsArray[i].Kills * (AbilityLevel * default.BonusPerLevel));
        }
    }

}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local float incPerc;

    if(Damage > 0 && InstigatedBy != None && ClassIsChildOf(DamageType, class'WeaponDamageType'))
    {
        incPerc = GetNumKillsForWeapon(
                    class<WeaponDamageType>(DamageType).default.WeaponClass,
                    TeamPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo),
                    AbilityLevel);

        if (Instigator.HasUDamage())
            incPerc = incPerc * 0.5f;

        Damage = Damage * (incPerc + 1.0);
    }
}

function ModifyWeapon(Weapon Weapon)
{
    local float incPerc;

    if(Weapon == None || PlayerController(RPRI.Controller) == None)
        return;

    if(InStr(Caps(string(Weapon)), "AVRIL") != -1) //hack for vinv avril
        incPerc = GetNumKillsForWeapon(
                    class'ONSAVRiL',
                    TeamPlayerReplicationInfo(RPRI.Controller.PlayerReplicationInfo),
                    AbilityLevel);
    else
        incPerc = GetNumKillsForWeapon(
                    Weapon.Class,
                    TeamPlayerReplicationInfo(RPRI.Controller.PlayerReplicationInfo),
                    AbilityLevel);

    PlayerController(RPRI.Controller).ReceiveLocalizedMessage(
        class'LocalMessage_WeaponProficiency',
        incPerc * 100,
        ,
        ,
        Weapon);
}

simulated function string DescriptionText()
{
    return Repl(
            Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel)),
            "$2", class'Util'.static.FormatPercent(MaxIncrease)
            );
}

defaultproperties
{
    BonusPerLevel=0.000500
    MaxIncrease=2.000000
    AbilityName="Weapons Proficiency"
    Description="This ability tracks the number of kills you achieve with your weapons and adds extra damage per kill. Each level of this ability adds $1 damage for every kill, up to +$2."
    StartingCost=20
    MaxLevel=10
    Category=Class'AbilityCategory_Weapons'
}
