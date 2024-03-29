//=============================================================================
// WeaponModifier_Energy.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Energy extends RPGWeaponModifier;

var localized string AdrenBonusText, AdrenLossText;

static function bool AllowedFor(class<Weapon> WeaponType, optional Pawn Other)
{
    if(!Super.AllowedFor(WeaponType, Other))
        return false;

    return (Other == None || (Other.Controller != None && Other.Controller.bAdrenalineEnabled));
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local float AdrenalineBonus;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if(Injured != InstigatedBy)
    {
        Identify();

        AdrenalineBonus = FMin(Damage, Injured.Health) * float(Modifier) * BonusPerLevel;

        //Adrenaline full
        if(
            UnrealPlayer(Instigator.Controller) != None &&
            Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax &&
            Instigator.Controller.Adrenaline + AdrenalineBonus >= Instigator.Controller.AdrenalineMax &&
            !Instigator.InCurrentCombo()
        )
        {
            UnrealPlayer(Instigator.Controller).ClientDelayedAnnouncementNamed('Adrenalin', 15);
        }

        Instigator.Controller.Adrenaline =
            FMin(Instigator.Controller.Adrenaline + AdrenalineBonus, Instigator.Controller.AdrenalineMax);
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();

    if(Modifier > 0) {
        AddToDescription(AdrenBonusText, BonusPerLevel);
    } else {
        AddToDescription(AdrenLossText, -BonusPerLevel);
    }
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    if(Modifier > 0)
        StaticAddToDescription(Description, Modifier, default.AdrenBonusText, default.BonusPerLevel);
    else
        StaticAddToDescription(Description, Modifier, default.AdrenLossText, -default.BonusPerLevel);

    return Description;
}

defaultproperties
{
    DamageBonus=0.040000
    BonusPerLevel=0.020000
    AdrenBonusText="$1 adrenaline gain"
    AdrenLossText="$1 adrenaline consumption"
    MinModifier=-3
    MaxModifier=4
    bCanHaveZeroModifier=False
    ModifierOverlay=Shader'EnergyShader'
    PatternPos="$W of Energy"
    PatternNeg="Draining $W"
    //AI
    AIRatingBonus=0.0125
}
