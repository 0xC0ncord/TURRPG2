//=============================================================================
// ArtificerAugment_Vorpal.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Vorpal extends ArtificerAugmentBase;

static function bool AllowedOn(WeaponModifier_Artificer WM, Weapon W)
{
    if(!Super.AllowedOn(WM, W))
        return false;

    return class'WeaponModifier_Vorpal'.static.AllowedFor(W.Class, W.Instigator);
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local RPGEffect Effect;

    if(Damage <= 0
        || InstigatedBy != Instigator
        || FRand() > BonusPerLevel
        || InstigatedBy.Controller == None
        || class'Util'.static.SameTeamP(Injured, InstigatedBy)
    )
    {
        return;
    }

    Effect = class'Effect_Vorpal'.static.Create(Injured, InstigatedBy.Controller);
    if(Effect != None)
        Effect.Start();
}

defaultproperties
{
    MaxLevel=1
    BonusPerLevel=0.01
    Description="$1 instant kill chance"
    LongDescription="When you deal damage to an enemy, there is a $1 chance per level that the enemy will be instantly killed."
    ModifierName="Vorpal"
    ModifierColor=(R=255,G=0,B=255)
    ModifierOverlay=Shader'TURRPG2.RPGWeapons.VorpalShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.VorpalIcon'
}
