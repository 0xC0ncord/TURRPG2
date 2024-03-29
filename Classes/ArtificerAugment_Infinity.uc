//=============================================================================
// ArtificerAugment_Infinity.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Infinity extends ArtificerAugmentBase;

static function bool AllowedOn(WeaponModifier_Artificer WM, Weapon W)
{
    local MutTURRPG RPGMut;

    RPGMut = class'MutTURRPG'.static.Instance(W.Level);
    if(RPGMut == None)
        return false;

    if(
        RPGMut.IsSuperWeapon(W.Class) ||
        RPGMut.IsSuperWeaponAmmo(W.AmmoClass[0]) ||
        RPGMut.IsSuperWeaponAmmo(W.AmmoClass[1])
    )
    {
        return false;
    }

    return Super.AllowedOn(WM, W);
}

function RPGTick(float dt)
{
    //TODO: Find a way for ballistic weapons
    Weapon.MaxOutAmmo();
}

defaultproperties
{
    MaxLevel=2
    ModifierName="Infinity"
    Description="infinite ammo"
    LongDescription="Grants infinite ammo."
    IconMaterial=Texture'TURRPG2.WOPIcons.InfinityIcon'
    ModifierOverlay=Shader'TURRPG2.WOPWeapons.InfinityShader'
    ModifierColor=(R=196,G=128)
}
