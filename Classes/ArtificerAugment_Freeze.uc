//=============================================================================
// ArtificerAugment_Freeze.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Freeze extends ArtificerAugmentBase;

var float FreezeMax;
var float FreezeDuration;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local RPGEffect Effect;

    if(Damage <= 0
        || Injured == InstigatedBy
        || InstigatedBy != Instigator
        || InstigatedBy.Controller == None
        || class'Util'.static.SameTeamP(Injured, InstigatedBy)
    )
        return;

    Effect = class'Effect_Freeze'.static.Create(
        Injured,
        InstigatedBy.Controller,
        float(Modifier) * FreezeDuration,
        1.0 - FMin(float(Modifier) * BonusPerLevel, FreezeMax)
    );
    if(Effect != None)
        Effect.Start();
}

function string GetDescription()
{
    return Repl(
        Repl(default.Description, "$1", class'Util'.static.FormatPercent(BonusPerLevel * Max(1, Modifier))),
        "$2", FreezeDuration * Max(1, Modifier)
    );
}

static function string StaticGetDescription(optional int Modifier)
{
    return Repl(
        Repl(default.Description, "$1", class'Util'.static.FormatPercent(default.BonusPerLevel * Max(1, Modifier))),
        "$2", default.FreezeDuration * Max(1, Modifier)
    );
}

static function string StaticGetLongDescription(optional int Modifier)
{
    return Repl(
        Repl(default.LongDescription, "$1", class'Util'.static.FormatPercent(default.BonusPerLevel * Max(1, Modifier))),
        "$2", default.FreezeDuration * Max(1, Modifier)
    );
}

defaultproperties
{
    ConflictsWith(0)=class'ArtificerAugment_PullForward'
    ConflictsWith(1)=class'ArtificerAugment_Knockback'
    ConflictsWith(2)=class'ArtificerAugment_NullEntropy'
    FreezeMax=0.90
    FreezeDuration=0.50
    MaxLevel=3
    BonusPerLevel=0.15
    ModifierName="Freeze"
    Description="slows targets $1 for $2s"
    LongDescription="For each level, slows targets by $1 for $2s."
    ModifierColor=(R=200,G=224,B=255)
    ModifierOverlay=Shader'TURRPG2.RPGWeapons.FreezeShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.FreezeIcon'
}
