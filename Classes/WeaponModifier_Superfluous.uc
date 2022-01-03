//=============================================================================
// WeaponModifier_Superfluous.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Superfluous extends RPGWeaponModifier;

var localized string SuperfluousText;
var localized string MinesText, GrenadesText;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
    if(!Super.AllowedFor(Weapon, Other))
        return false;
    return Weapon == class'ONSMineLayer' || Weapon == class'ONSGrenadeLauncher';
}

function StartEffect()
{
    ClientStartEffect();
}

function StopEffect()
{
    ClientStopEffect();
}

simulated function ClientStartEffect()
{
    if(ONSMineLayer(Weapon) != None)
        ONSMineLayer(Weapon).MaxMines += BonusPerLevel * Modifier;
    else if(ONSGrenadeLauncher(Weapon) != None)
        ONSGrenadeLauncher(Weapon).MaxGrenades += BonusPerLevel * Modifier;
}

simulated function ClientStopEffect()
{
    if(ONSMineLayer(Weapon) != None)
        ONSMineLayer(Weapon).MaxMines -= BonusPerLevel * Modifier;
    else if(ONSGrenadeLauncher(Weapon) != None)
        ONSGrenadeLauncher(Weapon).MaxGrenades -= BonusPerLevel * Modifier;
}

simulated function BuildDescription()
{
    Super.BuildDescription();

    if(ONSMineLayer(Weapon) != None)
        Description $= ", +" $ Repl(MinesText, "$1", int(2 * Modifier * BonusPerLevel));
    else if(ONSGrenadeLauncher(Weapon) != None)
        Description $= ", +" $ Repl(GrenadesText, "$1", int(2 * Modifier * BonusPerLevel));
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    Description $= ", +" $ Repl(default.SuperfluousText, "$1", int(2 * Modifier * default.BonusPerLevel));

    return Description;
}

defaultproperties
{
    SuperfluousText="$1 additional mines/grenades"
    MinesText="$1 additional mines"
    GrenadesText="$1 additional grenades"
    PatternPos="Superfluous $W"
    DamageBonus=0.04
    BonusPerLevel=1.00
    MinModifier=1
    MaxModifier=8
    bCanHaveZeroModifier=False
    ModifierOverlay=Shader'SuperfluousShader'
    //AI
    AIRatingBonus=0.3
}
