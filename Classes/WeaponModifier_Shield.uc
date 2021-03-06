//=============================================================================
// WeaponModifier_Shield.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Shield extends RPGWeaponModifier;

var config float RegenInterval;

var localized string ShieldText;

var float RegenTime;

function RestartRegenTimer() {
    RegenTime = Level.TimeSeconds + RegenInterval;
}

function StartEffect() {
    RestartRegenTimer();
}

function RPGTick(float dt) {
    local xPawn x;
    x = xPawn(Instigator);

    if(x != None && Level.TimeSeconds >= RegenTime) {
        if(x.ShieldStrength < x.ShieldStrengthMax)
            x.ShieldStrength = FMin(x.ShieldStrength + float(Modifier) * BonusPerLevel, x.ShieldStrengthMax);

        RestartRegenTimer();
    }
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    Super.AdjustPlayerDamage(Damage, OriginalDamage, InstigatedBy, HitLocation, Momentum, DamageType);

    if(Damage > 0) {
        RestartRegenTimer(); //reset on damage
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(Repl(
        Repl(ShieldText, "$1", int(BonusPerLevel) * Modifier),
        "$2", class'Util'.static.FormatFloat(RegenInterval)));
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, Repl(Repl(default.ShieldText, "$1", int(default.BonusPerLevel) * Modifier), "$2", class'Util'.static.FormatFloat(default.RegenInterval)));

    return Description;
}

defaultproperties
{
    ShieldText="$1 shield every $2s out of combat"
    PatternPos="$W of Shield"
    DamageBonus=0.04
    BonusPerLevel=1.00
    RegenInterval=2.00
    MinModifier=1
    MaxModifier=5
    //ModifierOverlay=TexEnvMap'TURRPG2.Overlays.goldenv' - for another weapon
    ModifierOverlay=TexEnvMap'PickupSkins.Shaders.TexEnvMap2'
    //AI
    AIRatingBonus=0.05
}
