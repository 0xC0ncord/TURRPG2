//=============================================================================
// Ability_EnergyLeech.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_EnergyLeech extends RPGAbility;

var float AdrenalineFraction;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int AdrenalineBonus;

    if(
        Damage <= 0 ||
        InstigatedBy == Injured ||
        InstigatedBy.Controller.SameTeamAs(Injured.Controller) ||
        InstigatedBy.Controller.Adrenaline >= InstigatedBy.Controller.AdrenalineMax ||
        InstigatedBy.InCurrentCombo() ||
        HasActiveArtifact(InstigatedBy) ||
        ClassIsChildOf(DamageType, class'RPGAdrenalineDamageType')
    )
    {
        return;
    }

    if(Vehicle(Injured) != None && Vehicle(Injured).IsVehicleEmpty())
        return;

    AdrenalineFraction += FMax(0, (FMin(Damage, Injured.Health)) * BonusPerLevel * AbilityLevel);

    AdrenalineBonus = int(AdrenalineFraction);
    AdrenalineFraction -= AdrenalineBonus;

    if(AdrenalineBonus > 0)
    {
        InstigatedBy.Controller.Adrenaline =
            FMin(InstigatedBy.Controller.Adrenaline + AdrenalineBonus, InstigatedBy.Controller.AdrenalineMax);

        if(
            UnrealPlayer(InstigatedBy.Controller) != None &&
            InstigatedBy.Controller.Adrenaline >= InstigatedBy.Controller.AdrenalineMax
        )
        {
            UnrealPlayer(InstigatedBy.Controller).ClientDelayedAnnouncementNamed('Adrenalin', 15);
        }
    }
}

static function bool HasActiveArtifact(Pawn Instigator)
{
    return class'RPGArtifact'.static.HasActiveArtifact(Instigator);
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Energy Leech"
    Description="Whenever you deal damage to an opponent, you gain $1 of the damage per level as adrenaline. This ability will not be triggered while you have an artifact active or for artifact-related damage."
    StartingCost=5
    CostAddPerLevel=5
    MaxLevel=5
    BonusPerLevel=0.010000
    Category=class'AbilityCategory_Adrenaline'
}
