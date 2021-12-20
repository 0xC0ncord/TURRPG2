//=============================================================================
// Effect_Shock.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Shock extends RPGEffect;

var float BaseDrainMultiplier;
var float ActiveArtifactDrainMultiplier;
var float ReducedDamageMultiplier;

var RPGPlayerReplicationInfo RPRI;

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    if(Other.Controller == None || !Other.Controller.bAdrenalineEnabled)
        return false;
    return Super.CanBeApplied(Other, Causer, Duration, Modifier);
}

function float GetAdrenalineDrain()
{
    if(Instigator.InCurrentCombo() || class'RPGArtifact'.static.HasActiveArtifact(Instigator))
        return Modifier * ActiveArtifactDrainMultiplier;
    return Modifier * BaseDrainMultiplier;
}

state Activated
{
    function Timer()
    {
        if(RPRI == None)
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Instigator.Controller);

        if(RPRI != None)
            RPRI.DrainAdrenaline(GetAdrenalineDrain(), self);
        else
            Instigator.Controller.Adrenaline = FMax(Instigator.Controller.Adrenaline - GetAdrenalineDrain(), 0);

        Super.Timer();
    }
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Victim, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if (Damage <= 0 || !ClassIsChildOf(DamageType, class'RPGAdrenalineDamageType'))
        return;

    Damage = Max(Damage, Damage * (1.0 - ReducedDamageMultiplier * Modifier));
}

defaultproperties
{
    BaseDrainMultiplier=2.000000
    ActiveArtifactDrainMultiplier=5.00000
    ReducedDamageMultiplier=0.150000
    TimerInterval=0.500000
    EffectClass=class'FX_Shock'
    EffectMessageClass=class'EffectMessage_Shock'
    EffectOverlay=Shader'ShockOverlay'
    StatusIconClass=class'StatusIcon_Shock'
}
