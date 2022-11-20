//=============================================================================
// ArtificerAugment_Force.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Force extends ArtificerAugmentBase;

const FORCE_RADIUS = 32768;

static function bool AllowedOn(Weapon W)
{
    local int x;

    if(!Super.AllowedOn(W))
        return false;

    for(x = 0; x < ArrayCount(W.FireModeClass); x++)
    {
        if (class<ProjectileFire>(W.FireModeClass[x]) != None)
            return true;
    }
}

function RPGTick(float dt)
{
    local Projectile Proj;
    local float Multiplier;

    Multiplier = 1.0f + BonusPerLevel * float(Modifier);

    foreach Instigator.CollidingActors(class'Projectile', Proj, FORCE_RADIUS)
    {
        if(Proj.Tag == 'Force' || Proj.Tag == 'Matrix')
            continue;

        if(Proj.Instigator != Instigator)
            continue;

        Proj.Tag = 'Force';
        class'Util'.static.ModifyProjectileSpeed(Proj, Multiplier, 'Force');
    }
}

defaultproperties
{
    MaxLevel=10
    BonusPerLevel=0.2
    ModifierName="Force"
    Description="$1 projectile speed"
    LongDescription="Increases weapon projectile speed by $1 per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.ForceIcon'
    ModifierOverlay=Shader'RPGWeapons.ForceShader'
    ModifierColor=(R=255)
}

