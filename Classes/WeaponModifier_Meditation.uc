//=============================================================================
// WeaponModifier_Meditation.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Meditation extends RPGWeaponModifier;

var config float RegenInterval;

var localized string MeditationText;

var float RegenTime;

function RestartRegenTimer()
{
    RegenTime = Level.TimeSeconds + RegenInterval;
}

function StartEffect()
{
    RestartRegenTimer();
}

function RPGTick(float dt)
{
    if(Level.TimeSeconds >= RegenTime)
    {
        if(!bIdentified)
            Identify();

        if(RPRI.Controller != None && RPRI.Controller.NeedsAdrenaline())
            RPRI.AwardAdrenaline(Modifier, self);

        RestartRegenTimer();
    }
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Super.AdjustPlayerDamage(Damage, OriginalDamage, InstigatedBy, HitLocation, Momentum, DamageType);

    if(Damage > 0)
    {
        RestartRegenTimer(); //reset on damage
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(Repl(
        Repl(MeditationText, "$1", int(BonusPerLevel) * Modifier),
        "$2", class'Util'.static.FormatFloat(RegenInterval)));
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, Repl(Repl(default.MeditationText, "$1", int(default.BonusPerLevel) * Modifier), "$2", class'Util'.static.FormatFloat(default.RegenInterval)));

    return Description;
}

defaultproperties
{
    MeditationText="$1 adrenaline every $2s out of combat"
    PatternPos="$W of Meditation"
    PatternNeg="$W of Frustration"
    DamageBonus=0.04
    BonusPerLevel=1.00
    RegenInterval=1.00
    MinModifier=-1
    MaxModifier=2
    bCanHaveZeroModifier=False
    ModifierOverlay=Combiner'MeditationShader'
    //AI
    AIRatingBonus=0.1
}
