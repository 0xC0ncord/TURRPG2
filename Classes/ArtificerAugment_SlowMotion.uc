//=============================================================================
// ArtificerAugment_SlowMotion.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_SlowMotion extends ArtificerAugment_Force;

defaultproperties
{
    ConflictsWith(0)=class'ArtificerAugment_Force'
    MaxLevel=3
    BonusPerLevel=-0.25
    ModifierName="Slow Motion"
    LongDescription="Decreases weapon projectile speed by $1 per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.ForceIcon'
}

