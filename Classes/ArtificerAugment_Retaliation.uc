//=============================================================================
// ArtificerAugment_Retaliation.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Retaliation extends ArtificerAugmentBase;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(
        InstigatedBy == None
        || Instigator == InstigatedBy
        || class'Util'.static.SameTeamP(InstigatedBy, Instigator)
    )
    {
        return;
    }

    InstigatedBy.TakeDamage(
        Max(1, int(float(Damage) * BonusPerLevel * Modifier)),
        Instigator,
        InstigatedBy.Location,
        vect(0, 0, 0),
        class'DamTypeRetaliation'
    );
}

defaultproperties
{
    MaxLevel=5
    BonusPerLevel=0.05
    ModifierName="Retaliation"
    Description="$1 dmg return"
    LongDescription="Causes attackers to take $1 damage per level each time you are struck."
    IconMaterial=Texture'TURRPG2.WOPIcons.RetaliationIcon'
    ModifierOverlay=Shader'WOPWeapons.RetaliationShader'
    ModifierColor=(R=188,G=72,B=57)
}

