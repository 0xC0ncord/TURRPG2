//=============================================================================
// WeaponModifier_QuadShot.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_QuadShot extends RPGWeaponModifier;

var localized string QuadShotText;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
    if(!Super.AllowedFor(Weapon, Other))
        return false;

    return (
        Weapon == class'ShockRifle' ||
        Weapon == class'LinkGun' ||
        Weapon == class'RPGLinkGun' ||
        Weapon == class'RocketLauncher' ||
        Weapon == class'RPGRocketLauncher' ||
        Weapon == class'SniperRifle' ||
        Weapon == class'ClassicSniperRifle' ||
        Weapon == class'BioRifle' ||
        InStr(Caps(string(Weapon)), "FLARELAUNCHER") != -1 ||
        InStr(Caps(string(Weapon)), "TURBOLASER") != -1 ||
        InStr(Caps(string(Weapon)), "SOAR") != -1 ||
        InStr(Caps(string(Weapon)), "PLASMAGUN") != -1 ||
        InStr(Caps(string(Weapon)), "HOWITZER") != -1 ||
        InStr(Caps(string(Weapon)), "PISTOL") != -1 ||
        InStr(Caps(string(Weapon)), "UNDERSLINGER") != -1 ||
        InStr(Caps(string(Weapon)), "WIDOWMAKER") != -1 ||
        InStr(Caps(string(Weapon)), "PARASITE") != -1
    );
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
    StartQuadShot(Weapon.GetFireMode(0));
    StartQuadShot(Weapon.GetFireMode(1));
}

simulated function ClientStopEffect()
{
    StopQuadShot(Weapon.GetFireMode(0));
    StopQuadShot(Weapon.GetFireMode(1));
}

simulated function StartQuadShot(WeaponFire FireMode)
{
    if(FireMode != None)
    {
        if(InstantFire(FireMode) != None)
            FireMode.Spread = 0.08;
        else if(
            ProjectileFire(FireMode) != None
            && ShockProjFire(FireMode) == None
            && InStr(Caps(string(Weapon.Class)), "TURBOLASER") == -1
        )
        {
            FireMode.Spread = 1400.0;
            ProjectileFire(FireMode).ProjPerFire = (ProjectileFire(FireMode).default.ProjPerFire * 4) / FireMode.AmmoPerFire;
        }
        FireMode.SpreadStyle = SS_Random;
    }
}

simulated function StopQuadShot(WeaponFire FireMode)
{
    if(FireMode != None)
    {
        FireMode.Spread = FireMode.default.Spread;
        FireMode.SpreadStyle = FireMode.default.SpreadStyle;
        if(ProjectileFire(FireMode) != None)
            ProjectileFire(FireMode).ProjPerFire = ProjectileFire(FireMode).default.ProjPerFire;
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();

    AddToDescription(QuadShotText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, default.QuadShotText);

    return Description;
}

defaultproperties
{
    QuadShotText="quad-shot"
    DamageBonus=-0.15
    PatternPos="Quad-shot $W"
    bCanHaveZeroModifier=True
    ModifierOverlay=Shader'QuadShotShader'
    //AI
    AIRatingBonus=0.45
}
