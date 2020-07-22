//=============================================================================
// WeaponModifier_Nullification.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Nullification extends RPGWeaponModifier;

var localized string MagicNullText;

var config array<class<RPGEffect> > DenyEffects;

function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier) {
    if(class'Util'.static.InArray(EffectClass, DenyEffects) >= 0) {
        Identify();
        return false;
    }

    return true;
}

simulated function BuildDescription() {
    Super.BuildDescription();
    AddToDescription(MagicNullText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.MagicNullText);

    return Description;
}

defaultproperties {
    MagicNullText="nullifies harmful effects"
    bCanHaveZeroModifier=True
    DamageBonus=0.050000
    MinModifier=4
    MaxModifier=6
    ModifierOverlay=Shader'AW-2k4XP.Weapons.ShockShieldShader'
    PatternPos="Nullifying $W"
    //Block effects
    DenyEffects(0)=class'DevoidEffect_Matrix'
    DenyEffects(1)=class'DevoidEffect_Vampire'
    DenyEffects(2)=class'Effect_Freeze'
    DenyEffects(3)=class'Effect_Knockback'
    DenyEffects(4)=class'Effect_NullEntropy'
    DenyEffects(5)=class'Effect_Poison'
    DenyEffects(6)=class'Effect_Vorpal'
    //AI
    CountersModifier(0)=class'WeaponModifier_Freeze'
    CountersModifier(1)=class'WeaponModifier_NullEntropy'
    CountersModifier(2)=class'WeaponModifier_Poison'
    CountersModifier(3)=class'WeaponModifier_Knockback'
    AIRatingBonus=0.025
}
