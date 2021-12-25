//=============================================================================
// WeaponModifier_Vorpal.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Vorpal extends RPGWeaponModifier;

var localized string VorpalText;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    local RPGEffect Vorpal;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if(Damage > 0 && Rand(99) <= (Modifier - MinModifier))
    {
        Identify();

        Vorpal = class'Effect_Vorpal'.static.Create(Injured, InstigatedBy.Controller);
        if(Vorpal != None)
            Vorpal.Start();
    }
}

simulated function BuildDescription() {
    Super.BuildDescription();

    AddToDescription(Repl(VorpalText, "$1",
        class'Util'.static.FormatPercent(0.01f * float(Modifier + 1 - MinModifier))));
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, Repl(default.VorpalText, "$1", class'Util'.static.FormatPercent(0.01f * float(Modifier + 1 - default.MinModifier))));

    return Description;
}

defaultproperties
{
    VorpalText="$1 instant kill chance"
    DamageBonus=0.10
    MinModifier=6
    MaxModifier=10
    ModifierOverlay=Shader'VorpalShader'
    PatternPos="Vorpal $W"
    ForbiddenWeaponTypes(0)=Class'XWeapons.AssaultRifle'
    ForbiddenWeaponTypes(1)=Class'XWeapons.FlakCannon'
    ForbiddenWeaponTypes(2)=Class'XWeapons.LinkGun'
    ForbiddenWeaponTypes(3)=Class'XWeapons.Minigun'
    //AI
    AIRatingBonus=0.10
}
