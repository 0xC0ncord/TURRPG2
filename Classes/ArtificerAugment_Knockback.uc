//=============================================================================
// ArtificerAugment_Knockback.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Knockback extends ArtificerAugmentBase;

static function bool CanApply(WeaponModifier_Artificer WM)
{
    // if(class'ArtificerAugment_PullForward'.static.GetFor(WM) != None
    //     || class'ArtificerAugment_Freeze'.static.GetFor(WM) != None
    //     || class'ArtificerAugment_NullEntropy'.static.GetFor(WM) != None
    //     || class'ArtificerAugment_Stone'.static.GetFor(WM) != None
    //     || class'ArtificerAugment_Propulsion'.static.GetFor(WM) != None
    // )
    //     return false;

    return Super.CanApply(WM);
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local Effect_Knockback Effect;

    if(Damage <= 0
        || Injured == InstigatedBy
        || InstigatedBy != Instigator
        || InstigatedBy.Controller == None
        || class'Util'.static.SameTeamP(Injured, InstigatedBy)
    )
        return;

    Effect = Effect_Knockback(class'Effect_Knockback'.static.Create(Injured, InstigatedBy.Controller, 1f));
    if(Effect != None)
    {
        if(Momentum == vect(0, 0, 0)
            || DamageType == class'DamTypeSniperShot'
            || DamageType == class'DamTypeClassicSniper'
            || DamageType == class'DamTypeLinkShaft'
            || DamageType == class'DamTypeONSAVRiLRocket'
        )
        {
            Momentum = (Normal(InstigatedBy.Location - HitLocation) * -200f)
                        * FMax(2f, FMax(float(ModifierLevel) * BonusPerLevel, float(Damage) * 0.1f));
        }
        else
        {
            Momentum = (Normal(InstigatedBy.Location - Injured.Location) * -200f)
                        * FMax(2f, FMax(float(ModifierLevel) * BonusPerLevel, float(Damage) * 0.1f));
        }

        // momentum will be applied by the weapon
        Effect.Momentum = vect(0, 0, 0);
        Effect.Start();
    }
}

defaultproperties
{
    MaxLevel=4
    ModifierName="Knockback"
    Description="knockback"
    LongDescription="Causes your weapon to knock targets away."
    ModifierColor=(R=255)
    ModifierOverlay=Shader'TURRPG2.RPGWeapons.KnockbackShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.KnockbackIcon'
}
