//=============================================================================
// ProjAugment_Bombing.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ProjAugment_Bombing extends RPGProjectileAugment;

var WeaponModifier_Artificer WeaponModifier;

var bool bNewTimer;

function StartEffect()
{
    bNewTimer = true;
}

function StopEffect()
{
    SetTimer(0.0, false);
}

function Tick(float dt)
{
    //wait until we are far enough away before dropping bombs
    if(
        bNewTimer
        && (
            Instigator.Location.Z - Proj.Location.Z + Instigator.CollisionHeight > Proj.DamageRadius
            || VSize(Instigator.Location - Proj.Location) > Proj.DamageRadius
        )
    )
    {
        bNewTimer = false;
        SetTimer(FRand() * 0.5, false);
    }
}

function Timer()
{
    local Projectile P;
    local vector SpawnLoc;
    local ArtificerAugmentBase Augment;
    local int Flags;

    if(!bTimerLoop)
        SetTimer(0.5, true);

    SpawnLoc = Proj.Location;
    if(Proj.bProjTarget)
        SpawnLoc -= vect(0, 0, 1) * (2 * Proj.CollisionHeight + 1);

    P = Instigator.Spawn(Proj.Class, Self,, SpawnLoc, rot(-16384, 0, 0));
    if(P == None)
        return;

    //15% original stats
    P.Damage *= 0.15;
    P.MomentumTransfer *= 0.15;

    //let other augments modify this
    for(Augment = WeaponModifier.AugmentList; Augment != None; Augment = Augment.NextAugment)
    {
        if(ArtificerAugmentBase_ProjectileMod(Augment) != None)
        {
            //... but not bombing
            if(ArtificerAugment_Bombing(Augment) == None)
                ArtificerAugmentBase_ProjectileMod(Augment).ModifyProjectile(P);
            Flags = Flags | ArtificerAugmentBase_ProjectileMod(Augment).ModFlag;
        }
    }
    P.SetPropertyText("Tag", string(Flags));
}

defaultproperties
{
}
