//=============================================================================
// ArtificerAugment_Poison.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Poison extends ArtificerAugmentBase;

var localized string PoisonText, PoisonAbsText;
var localized string LongPoisonText, LongPoisonAbsText;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local Effect_Poison Effect;

    if(Damage <= 0
        || InstigatedBy != Instigator
        || InstigatedBy.Controller == None
        || class'Util'.static.SameTeamP(Injured, InstigatedBy)
    )
        return;

    Effect = Effect_Poison(class'Effect_Poison'.static.Create(
        Injured,
        InstigatedBy.Controller,
        Modifier,
        Modifier
    ));
    if(Effect != None)
    {
        Effect.PoisonMode = EPoisonMode(class'WeaponModifier_Poison'.default.PoisonMode);
        Effect.BasePercentage = class'WeaponModifier_Poison'.default.BasePercentage;
        Effect.Curve = class'WeaponModifier_Poison'.default.Curve;
        Effect.AbsDrainPerLevel = class'WeaponModifier_Poison'.default.AbsDrainPerLevel;
        Effect.PercDrainPerLevel = class'WeaponModifier_Poison'.default.PercDrainPerLevel;
        Effect.MinHealth = class'WeaponModifier_Poison'.default.MinHealth;
        Effect.Start();
    }
}

function string GetDescription()
{
    if(EPoisonMode(class'WeaponModifier_Poison'.default.PoisonMode) == PM_Absolute)
        return Repl(PoisonAbsText, "$1", class'Util'.static.FormatFloat(Modifier));

    return PoisonText;
}

static function string StaticGetDescription(optional int Modifier)
{
    if(EPoisonMode(class'WeaponModifier_Poison'.default.PoisonMode) == PM_Absolute)
        return Repl(default.PoisonAbsText, "$1", class'Util'.static.FormatFloat(Modifier));

    return default.PoisonText;
}

static function string StaticGetLongDescription(optional int Modifier)
{
    if(EPoisonMode(class'WeaponModifier_Poison'.default.PoisonMode) == PM_Absolute)
    {
        return Repl(
            Repl(default.LongPoisonAbsText, "$1", class'Util'.static.FormatFloat(Modifier)),
            "$2",
            class'Util'.static.FormatFloat(Modifier)
        );
    }

    return default.LongPoisonText;
}

defaultproperties
{
    MaxLevel=10
    PoisonText="poisons targets"
    LongPoisonText="Causes your weapon to poison targets. Higher levels make the poison effect deal more damage and last longer."
    PoisonAbsText="poisons targets $1 health/s"
    LongPoisonAbsText="Causes your weapon to poison targets for $1 health every second. Each level of this augment makes the poison last $2s longer."
    ModifierName="Poison"
    ModifierColor=(G=255)
    ModifierOverlay=Shader'TURRPG2.RPGWeapons.PoisonShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.PoisonIcon'
}
