//=============================================================================
// WeaponModifier_Retaliation.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Retaliation extends RPGWeaponModifier;

var localized string RetalText;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int RetalDamage;

    Super.AdjustPlayerDamage(Damage, OriginalDamage, InstigatedBy, HitLocation, Momentum, DamageType);
    Identify();

    if(InstigatedBy == None || DamageType == class'DamTypeCounterShove' || DamageType == class'DamTypeRetaliation')
        return;

    //TODO effect system
    if(class'WeaponModifier_Nullification'.static.GetFor(InstigatedBy.Weapon) != None)
        return;

    if(InstigatedBy != Instigator && (InstigatedBy.Controller == None || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)))
    {
        RetalDamage = int(float(Modifier) * BonusPerLevel * float(Damage));
        RetalDamage = FMin(RetalDamage, float(Instigator.Health));

        if(RetalDamage > 0)
        {
            InstigatedBy.TakeDamage(
                RetalDamage,
                Instigator,
                InstigatedBy.Location,
                vect(0, 0, 0),
                class'DamTypeRetaliation');
        }
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(RetalText, BonusPerLevel);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.RetalText, default.BonusPerLevel);

    return Description;
}

defaultproperties
{
    RetalText="$1 dmg return"
    DamageBonus=0.04
    BonusPerLevel=0.05
    MinModifier=1
    MaxModifier=8
    ModifierOverlay=Shader'UT2004Weapons.Shaders.RedShockFall'
    PatternPos="$W of Retaliation"
    //AI
    AIRatingBonus=0.025
    /*
        This weapon type doesn't actually counter these damage types, but since
        they usually mean a lot of damage, it is advantageous to pick this.
    */
    CountersDamage(0)=class'DamTypeONSMine'
    CountersDamage(1)=class'DamTypeONSGrenade'
    CountersDamage(2)=class'DamTypeRocket'
    CountersDamage(3)=class'DamTypeRocketHoming'
    CountersDamage(4)=class'DamTypeFlakShell'
}
