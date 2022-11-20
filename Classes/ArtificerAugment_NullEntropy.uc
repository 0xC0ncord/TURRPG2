//=============================================================================
// ArtificerAugment_NullEntropy.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_NullEntropy extends ArtificerAugmentBase;

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

    Effect = class'Effect_NullEntropy'.static.Create(
        Injured,
        InstigatedBy.Controller,
        FMax(1, BonusPerLevel * float(Modifier))
    );
    if(Effect != None)
    {
        Momentum = vect(0, 0, 0);
        Effect.Start();
    }
}

function string GetDescription()
{
    return Repl(Description, "$1", class'Util'.static.FormatFloat(BonusPerLevel * Max(1, Modifier)));
}

static function string StaticGetDescription(optional int Modifier)
{
    return Repl(default.Description, "$1", class'Util'.static.FormatFloat(default.BonusPerLevel * Max(1, Modifier)));
}

static function string StaticGetLongDescription(optional int Modifier)
{
    return Repl(default.Description, "$1", class'Util'.static.FormatFloat(default.BonusPerLevel * Max(1, Modifier)));
}

defaultproperties
{
    ConflictsWith(0)=class'ArtificerAugment_PullForward'
    ConflictsWith(1)=class'ArtificerAugment_Freeze'
    ConflictsWith(2)=class'ArtificerAugment_Knockback'
    MaxLevel=1
    BonusPerLevel=0.50
    ModifierName="Null Entropy"
    Description="null entropy for $1s"
    LongDescription="Causes your weapon to inflict null entropy for $1s."
    ModifierColor=(R=128,G=196,B=255)
    ModifierOverlay=Shader'MutantSkins.Shaders.MutantGlowShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.NullEntropyIcon'
}
