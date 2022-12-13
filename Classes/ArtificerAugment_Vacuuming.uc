//=============================================================================
// ArtificerAugment_Vacuuming.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Vacuuming extends ArtificerAugmentBase_ProjectileMod;

function ModifyProjectile(Projectile Proj)
{
    Proj.MomentumTransfer = 0f;
    class'ProjAugment_Vacuuming'.static.Create(Proj, 1.0f + BonusPerLevel * float(Modifier), ModFlag);
}

defaultproperties
{
    ModFlag=F_PROJMOD_VACUUMING
    MaxLevel=5
    BonusPerLevel=0.06
    ModifierName="Vacuuming"
    Description="$1 vacuum wave"
    LongDescription="Creates an implosion when projectiles explode that sucks in nearby enemies, but does not do any damage by itself. The radius of this implosion is increased by $1 per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.ForceIcon'
    ModifierOverlay=Combiner'WOPWeapons.VacuumShader'
    ModifierColor=(R=44,B=224)
}
