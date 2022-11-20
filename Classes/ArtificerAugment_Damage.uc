//=============================================================================
// ArtificerAugment_Damage.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Damage extends ArtificerAugmentBase;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Damage += float(OriginalDamage) * Modifier * BonusPerLevel;
}

defaultproperties
{
    MaxLevel=10
    BonusPerLevel=0.02
    ModifierName="Damage"
    IconMaterial=Texture'TURRPG2.WOPIcons.DamageIcon'
    ModifierOverlay=Shader'WOPWeapons.DamageShader'
    ModifierColor=(R=255,B=255)
}
