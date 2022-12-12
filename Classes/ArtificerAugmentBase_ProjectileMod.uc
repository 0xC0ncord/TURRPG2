//=============================================================================
// ArtificerAugmentBase_ProjectileMod.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugmentBase_ProjectileMod extends ArtificerAugmentBase
    abstract;

const PROJ_SEARCH_RADIUS = 768;
var const int ModFlag;

static function bool AllowedOn(WeaponModifier_Artificer WM, Weapon W)
{
    local int x;

    if(!Super.AllowedOn(WM, W))
        return false;

    for(x = 0; x < ArrayCount(W.FireModeClass); x++)
    {
        if (class<ProjectileFire>(W.FireModeClass[x]) != None)
            return true;
    }
}

static function bool CanModifyProjectile(Projectile Proj)
{
    //check for null tag, likely a child flak chunk or something
    return Proj.Tag != 'None' && !bool(int(string(Proj.Tag)) & default.ModFlag);
}

function RPGTick(float dt)
{
    local Projectile Proj;

    foreach Instigator.CollidingActors(class'Projectile', Proj, PROJ_SEARCH_RADIUS)
    {
        if(Proj.Instigator != Instigator)
            continue;

        if(!default.Class.static.CanModifyProjectile(Proj))
            continue;

        ModifyProjectile(Proj);

        Proj.SetPropertyText("Tag", string(int(string(Proj.Tag)) | ModFlag));
    }
}

function ModifyProjectile(Projectile P);

defaultproperties
{
}
