//=============================================================================
// ArtificerAugment_Protection.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Protection extends ArtificerAugmentBase;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Damage -= Damage * (BonusPerLevel * Modifier);
}

defaultproperties
{
    MaxLevel=10
    BonusPerLevel=0.1
    ModifierName="Protection"
    Description="$1 dmg reduction"
    LongDescription="Grants $1 damage reduction per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.ProtectionIcon'
    ModifierOverlay=Shader'RPGWeapons.ProtectionShader'
    ModifierColor=(R=255,G=255)
}
