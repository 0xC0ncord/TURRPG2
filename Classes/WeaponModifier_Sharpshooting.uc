//=============================================================================
// WeaponModifier_Sharpshooting.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Sharpshooting extends RPGWeaponModifier;

const NUM_FIRE_MODES = 2;

var localized string SharpshootingText;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
    local int i;

    if(!Super.AllowedFor(Weapon, Other))
        return false;

    for(i = 0; i < NUM_FIRE_MODES; i++)
        if(Weapon.default.FireModeClass[i] != None && Weapon.default.FireModeClass[i].default.Spread > 0)
            return true;

    return false;
}

function StartEffect()
{
    if(!bIdentified)
        Identify();

    ClientStartEffect();
}

function StopEffect()
{
    ClientStopEffect();
}

simulated function ClientStartEffect()
{
    local int i;
    local WeaponFire WF;

    for(i = 0; i < NUM_FIRE_MODES; i++)
    {
        WF = Weapon.GetFireMode(i);
        if(WF != None && WF.Spread > 0)
            WF.Spread = WF.default.Spread - (WF.default.Spread * Modifier * BonusPerLevel);
    }
}

simulated function ClientStopEffect()
{
    local int i;
    local WeaponFire WF;

    for(i = 0; i < NUM_FIRE_MODES; i++)
    {
        WF = Weapon.GetFireMode(i);
        if(WF != None && WF.Spread > 0)
            WF.Spread = WF.default.Spread;
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(SharpshootingText, BonusPerLevel);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.SharpshootingText);

    return Description;
}

defaultproperties
{
    SharpshootingText="$1 decreased weapon spread"
    BonusPerLevel=0.2
    DamageBonus=0.02
    PatternPos="Sharpshooting $W"
    MinModifier=1
    MaxModifier=4
    bCanHaveZeroModifier=False
    ModifierOverlay=Combiner'SharpshootingShader'
    //AI
    AIRatingBonus=0.35
}
