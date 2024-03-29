//=============================================================================
// WeaponModifier_Rage.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Rage extends RPGWeaponModifier;

var config float DamageReturn;
var config int MinimumHealth;

var localized string RageText;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int localDamage;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    Identify();
    if(Damage > 0)
    {
        localDamage = int(FMax(1.0, DamageReturn * float(Damage)));

        if(localDamage >= Instigator.Health - MinimumHealth)
        {
            localDamage = Instigator.Health - MinimumHealth;
        }

        if(localDamage > 0 && (InstigatedBy.Controller == None || !InstigatedBy.Controller.bGodMode))
            Instigator.Health = Max(1, Instigator.Health - localDamage); //make sure you can never reach 0, as that causes evil bugs
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(Repl(RageText, "$2", MinimumHealth), DamageReturn);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, Repl(default.RageText, "$2", default.MinimumHealth), default.DamageReturn);

    return Description;
}

defaultproperties
{
    RageText="$1 self-damage down to $2"
    DamageBonus=0.10
    DamageReturn=0.10
    MinimumHealth=70
    MinModifier=6
    MaxModifier=10
    ModifierOverlay=Combiner'RageShader'
    PatternPos="$W of Rage"
    ForbiddenWeaponTypes(0)=Class'XWeapons.LinkGun'
    ForbiddenWeaponTypes(1)=Class'XWeapons.Minigun'
    ForbiddenWeaponTypes(2)=Class'XWeapons.AssaultRifle'
    ForbiddenWeaponTypes(3)=Class'XWeapons.ShieldGun'
    ForbiddenWeaponTypes(4)=Class'XWeapons.TransLauncher'
    //AI
    AIRatingBonus=0.075
}
