//=============================================================================
// ArtificerAugment_Resupply.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Resupply extends ArtificerAugmentBase;

var float NextEffectTime;

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
    NextEffectTime -= dt;

    if(NextEffectTime > 0)
        return;

    Weapon.AddAmmo(Modifier * (1 + Weapon.AmmoClass[0].default.MaxAmmo / 100), 0);
    if(Weapon.AmmoClass[0] != Weapon.AmmoClass[1] && Weapon.AmmoClass[1] != None)
        Weapon.AddAmmo(Modifier * (1 + Weapon.AmmoClass[1].default.MaxAmmo / 100), 1);

    NextEffectTime += 3f;
}

function StartEffect()
{
    NextEffectTime = 3f;
}

defaultproperties
{
    MaxLevel=5
    ModifierName="Resupply"
    Description="regens ammo"
    LongDescription="Regenerates ammo for your weapon every second. Each level doubles, triples, etc. the amount of ammo regenerated."
    IconMaterial=Texture'TURRPG2.WOPIcons.ResupplyIcon'
    ModifierOverlay=Shader'WOPWeapons.ResupplyShader'
    ModifierColor=(R=255,G=215,B=188)
}
