//=============================================================================
// ArtificerAugment_Infinity.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Infinity extends ArtificerAugmentBase;

function RPGTick(float dt)
{
    //TODO: Find a way for ballistic weapons
    Weapon.MaxOutAmmo();
}

defaultproperties
{
    ModifierName="Infinity"
    Description="infinite ammo"
    LongDescription="Grants infinite ammo."
    ModifierOverlay=Shader'TURRPG2.WOPWeapons.InfinityShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.InfinityIcon'
}
