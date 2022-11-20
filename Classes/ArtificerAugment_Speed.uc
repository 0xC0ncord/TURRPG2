//=============================================================================
// ArtificerAugment_Speed.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Speed extends ArtificerAugmentBase;

function StartEffect()
{
    class'Util'.static.PawnScaleSpeed(Instigator, 1.0 + (BonusPerLevel * Modifier));
}

function StopEffect()
{
    class'Util'.static.PawnScaleSpeed(Instigator, 1 / (1.0 + (BonusPerLevel * Modifier)));
}

defaultproperties
{
    MaxLevel=10
    BonusPerLevel=0.10
    ModifierName="Speed"
    Description="$1 movement speed"
    LongDescription="Increases your overall movement speed by $1 per level while your weapon is held."
    IconMaterial=Texture'TURRPG2.WOPIcons.SpeedIcon'
    ModifierOverlay=Shader'RPGWeapons.SpeedShader'
    ModifierColor=(R=255,G=128,B=255)
}

