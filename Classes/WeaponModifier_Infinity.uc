//=============================================================================
// WeaponModifier_Infinity.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Infinity extends RPGWeaponModifier;

var localized string InfAmmoText;

function WeaponFire(byte Mode)
{
    Identify();
}

function RPGTick(float dt)
{
    //TODO: Find a way for ballistic weapons
    Weapon.MaxOutAmmo();
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(InfAmmoText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    StaticAddToDescription(Description, Modifier, default.InfAmmoText);

    return Description;
}

defaultproperties
{
    bAllowForSpecials=False

    InfAmmoText="infinite ammo"
    DamageBonus=0.050000
    MinModifier=-3
    MaxModifier=8
    ModifierOverlay=Shader'InfinityShader'
    PatternPos="$W of Infinity"
    PatternNeg="$W of Infinity"
    bCanHaveZeroModifier=True
    //AI
    AIRatingBonus=0.025000
}
