//=============================================================================
// ArtificerAugment_Sturdy.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Sturdy extends ArtificerAugmentBase;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Momentum *= (1f - (BonusPerLevel * Modifier));
}

defaultproperties
{
    MaxLevel=3
    BonusPerLevel=0.30
    ModifierName="Sturdy"
    Description="$1 momentum reduction"
    LongDescription="Reduces all momentum transferred to you by $1 per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.SturdyIcon'
    ModifierOverlay=Shader'RPGWeapons.SturdyShader'
    ModifierColor=(R=128,G=224,B=255)
}
