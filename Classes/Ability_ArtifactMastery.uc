//=============================================================================
// Ability_ArtifactMastery.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ArtifactMastery extends RPGAbility;

var float AdrenalineDamageBonusPerLevel;
var float WeaponDamagePenaltyPerLevel, VehicleDamagePenaltyPerLevel;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Damage > 0 && InstigatedBy == RPRI.Controller.Pawn)
    {
        if(ClassIsChildOf(DamageType, class'RPGAdrenalineDamageType'))
            Damage = Damage + (Damage * AdrenalineDamageBonusPerLevel * AbilityLevel);
        else if(ClassIsChildOf(DamageType, class'WeaponDamageType'))
            Damage = Damage - (Damage * WeaponDamagePenaltyPerLevel * AbilityLevel);
        else if(ClassIsChildOf(DamageType, class'VehicleDamageType'))
            Damage = Damage - (Damage * VehicleDamagePenaltyPerLevel * AbilityLevel);
    }
}

function ModifyPawn(Pawn Other)
{
    local Inventory Inv;

    Super.ModifyPawn(Other);

    for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
        if(RPGArtifact(Inv) != None && RPGArtifact(Inv).CostPerSec > 0)
            RPGArtifact(Inv).AdrenalineUsage = 1 - (BonusPerLevel * AbilityLevel);
}

function ModifyArtifact(RPGArtifact A)
{
    if(A.CostPerSec > 0)
        A.AdrenalineUsage = 1 - (BonusPerLevel * AbilityLevel);
}

simulated function string DescriptionText()
{
    return Repl(Repl(Repl(Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel)), "$2", class'Util'.static.FormatPercent(AdrenalineDamageBonusPerLevel)), "$3", class'Util'.static.FormatPercent(WeaponDamagePenaltyPerLevel)), "$4", class'Util'.static.FormatPercent(VehicleDamagePenaltyPerLevel));
}

defaultproperties
{
    BonusPerLevel=0.05
    AdrenalineDamageBonusPerLevel=0.05
    WeaponDamagePenaltyPerLevel=0.02
    VehicleDamagePenaltyPerLevel=0.02
    AbilityName="Artifact Mastery"
    Description="For every level of this ability, your adrenaline usage from artifacts is reduced by $1 and your artifact damage is increased by $2. Consequently, every level of this ability will reduce your overall weapon damage by $3 and overall vehicular damage by $4."
    StartingCost=10
    CostAddPerLevel=2
    MaxLevel=10
    Category=class'AbilityCategory_Artifacts'
}
