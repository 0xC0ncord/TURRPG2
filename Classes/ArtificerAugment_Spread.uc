//=============================================================================
// ArtificerAugment_Spread.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Spread extends ArtificerAugmentBase_FireMode;

var int SpreadLinkAmmoCost, SpreadBioAmmoCost;

defaultproperties
{
    SpreadLinkAmmoCost=2
    SpreadBioAmmoCost=2
    FireModes(0)=(WeaponClass=Class'XWeapons.LinkGun',FireMode=Class'ArtificerFireMode_SpreadLink')
    FireModes(1)=(WeaponClass=Class'TURRPG2.RPGLinkGun',FireMode=Class'ArtificerFireMode_SpreadLink')
    FireModes(2)=(WeaponClass=Class'XWeapons.BioRifle',FireMode=Class'ArtificerFireMode_SpreadBio')
    MaxLevel=2
    ModifierName="Spread"
    Description="spread fire"
    LongDescription="Grants the Bio-Rifle or Link Gun spread fire modes."
    ModifierOverlay=Shader'WOPWeapons.SpreadShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.SpreadIcon'
    ModifierColor=(R=128,B=128)
}
