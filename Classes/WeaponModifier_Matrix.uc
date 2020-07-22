//=============================================================================
// WeaponModifier_Matrix.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Matrix extends RPGWeaponModifier;

var config float MatrixRadius;
var config array<name> Ignore;

var localized string MatrixText;

const SLOWDOWN_CAP = 0.1;

var RPGMatrixField Field;

function StartEffect() {
    Field = Spawn(class'RPGMatrixField', Instigator.Controller,, Instigator.Location, Instigator.Rotation);
    Field.SetBase(Instigator);
    Field.Radius = MatrixRadius;
    Field.Multiplier = FMax(SLOWDOWN_CAP, 1.0f - BonusPerLevel * float(Modifier));
    Field.OnMatrix = OnMatrix;
    Field.Ignore = Ignore;
}

function StopEffect() {
    Field.Destroy();
}

function OnMatrix(RPGMatrixField Field, Projectile Proj, float Multiplier) {
    Identify();
}

simulated function BuildDescription()
{
    local float Multiplier;

    Super.BuildDescription();

    Multiplier = FMin(1 - SLOWDOWN_CAP, BonusPerLevel * float(Modifier));
    AddToDescription(Repl(MatrixText, "$1", class'Util'.static.FormatPercent(Multiplier)));
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;
    local float Multiplier;

    Description = Super.StaticGetDescription(Modifier);

    Multiplier = FMin(1 - SLOWDOWN_CAP, default.BonusPerLevel * float(Modifier));
    StaticAddToDescription(Description, Modifier, Repl(default.MatrixText, "$1", class'Util'.static.FormatPercent(Multiplier)));

    return Description;
}

defaultproperties
{
    MatrixText="$1 enemy projectile slowdown"
    DamageBonus=0.03

    MatrixRadius=768
    BonusPerLevel=0.20

    MinModifier=1
    MaxModifier=4
    ModifierOverlay=ColorModifier'TURRPG2.Shaders.MatrixColorModifier'
    PatternPos="Matrix $W"
    //AI
    AIRatingBonus=0.025000
    CountersDamage(0)=class'DamTypeFlakChunk'
    CountersDamage(1)=class'DamTypeFlakShell'
    CountersDamage(2)=class'DamTypeRocket'
    CountersDamage(3)=class'DamTypeRocketHoming'
}
