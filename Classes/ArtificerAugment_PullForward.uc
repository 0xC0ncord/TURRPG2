//=============================================================================
// ArtificerAugment_PullForward.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_PullForward extends ArtificerAugmentBase;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local Effect_PullForward Effect;

    if(Damage <= 0
        || Injured == InstigatedBy
        || InstigatedBy != Instigator
        || InstigatedBy.Controller == None
        || class'Util'.static.SameTeamP(Injured, InstigatedBy)
    )
        return;

    Effect = Effect_PullForward(class'Effect_PullForward'.static.Create(Injured, InstigatedBy.Controller, 1f));
    if(Effect != None)
    {
        if(Momentum == vect(0, 0, 0)
            || DamageType == class'DamTypeSniperShot'
            || DamageType == class'DamTypeClassicSniper'
            || DamageType == class'DamTypeLinkShaft'
            || DamageType == class'DamTypeONSAVRiLRocket'
        )
        {
            if(InstigatedBy == Injured)
                Momentum = InstigatedBy.Location - HitLocation;
            else
                Momentum = InstigatedBy.Location - Injured.Location;
        }

        Momentum *= FMax(2f, FMax(float(Modifier) * BonusPerLevel, float(Damage) * 0.1)) * -1;

        // momentum will be applied by the weapon
        Effect.Momentum = vect(0, 0, 0);
        Effect.Start();
    }
}

defaultproperties
{
    ConflictsWith(0)=class'ArtificerAugment_Knockback'
    ConflictsWith(1)=class'ArtificerAugment_Freeze'
    ConflictsWith(2)=class'ArtificerAugment_NullEntropy'
    MaxLevel=10
    ModifierName="Pull Forward"
    Description="pulls targets toward you"
    LongDescription="Causes your weapon to pull targets towards you."
    ModifierColor=(R=224,G=224,B=255)
    ModifierOverlay=Shader'TURRPG2.RPGWeapons.PullForwardShader'
    IconMaterial=Texture'TURRPG2.WOPIcons.PullForwardIcon'
}
