//=============================================================================
// ArtificerAugment_Bombing.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Bombing extends ArtificerAugmentBase_ProjectileMod;

var() float BombFrequency;

function ModifyProjectile(Projectile P)
{
    local ProjAugment_Bombing A;

    A = ProjAugment_Bombing(class'ProjAugment_Bombing'.static.Create(P, BombFrequency * (1 - (BonusPerLevel * (Modifier - 1)))));
    A.WeaponModifier = WeaponModifier;
    A.StartEffect();
}

defaultproperties
{
    ModFlag=F_PROJMOD_BOMBING
    BombFrequency=1.0
    MaxLevel=3
    BonusPerLevel=0.33
    ModifierName="Bombing"
    Description="in-flight bombing Projectiles"
    LongDescription="Causes in-flight projectiles to carpet bomb as they travel by creating more copies of themselves. Each level of this augment increases the frequency projectiles are created by $1."
    IconMaterial=Texture'TURRPG2.WOPIcons.ForceIcon'
    ModifierOverlay=Combiner'WOPWeapons.BombingShader'
    ModifierColor=(R=255,G=150)
}
