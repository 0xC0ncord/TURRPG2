//=============================================================================
// WeaponModifier_Flight.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Flight extends RPGWeaponModifier;

var Emitter FX;
var bool bEnvironmentalEffectDisabled;

var localized string FlightText;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
    if(ClassIsChildOf(Weapon, class'Painter'))
        return false;
    return Super.AllowedFor(Weapon, Other);
}

function RPGTick(float dt)
{
    if(Instigator.Physics == PHYS_None && Instigator.Physics != PHYS_Spider)
    {
        if(Instigator.HeadVolume.KBuoyancy == 0.999999)
            bEnvironmentalEffectDisabled = true;
        else
            bEnvironmentalEffectDisabled = false;
        StartEffect();
    }
}

function StartEffect()
{
    if(!bIdentified)
        Identify();

    if(bEnvironmentalEffectDisabled)
    {
        StopEffect();
        return;
    }

    if(Instigator.Physics == PHYS_Flying || Instigator.Physics == PHYS_None || Instigator.Physics == PHYS_Spider)
        return;

    if(PlayerController(Instigator.Controller) != None)
    {
        if(Instigator.TouchingWaterVolume())
            Instigator.Controller.GotoState(Instigator.WaterMovementState);
        else
        {
            Instigator.Controller.GotoState('PlayerFlying');
            if(FX == None)
            {
                FX = Instigator.Spawn(class'FX_Flight', Instigator,, Instigator.Location);
                FX.SetBase(Instigator);
            }
        }
    }
}

function StopEffect()
{
    if(class'Artifact_Flight'.static.IsActiveFor(Instigator))
        return;

    if(PlayerController(Instigator.Controller) != None)
    {
        if(Instigator.TouchingWaterVolume())
            Instigator.Controller.GotoState(Instigator.WaterMovementState);
        else
            Instigator.Controller.GotoState(Instigator.LandMovementState);
    }

    if(FX != None)
        FX.Kill();
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Instigator.Physics == PHYS_Flying)
        Momentum = Momentum * 4f / FMin(2f, (1f + BonusPerLevel * Modifier));
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(FlightText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.FlightText);

    return Description;
}

defaultproperties
{
    BonusPerLevel=0.250000
    DamageBonus=0.010000
    FlightText="allows flight"
    MaxModifier=4
    bCanHaveZeroModifier=True
    ModifierOverlay=FinalBlend'FlightShader'
    PatternPos="$W of Flight"
    //AI
    AIRatingBonus=0.0125
}
