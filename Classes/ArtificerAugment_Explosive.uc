//=============================================================================
// ArtificerAugment_Explosive.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Explosive extends ArtificerAugmentBase;

var() class<DamageType> MyDamageType;
var() float DefaultDamageRadius;
var float DamageRadius;

function SetLevel(int NewLevel)
{
    Super.SetLevel(NewLevel);
    DamageRadius = DefaultDamageRadius * (1.0f + BonusPerLevel * float(Modifier));
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int i;
    local class<InstantFire> WF;
    local float damageScale, dist;
    local vector dir;
    local Actor Victims;

    if(DamageType == MyDamageType || class<WeaponDamageType>(DamageType) == None)
        return;

    for(i = 0; i < 2; i++)
    {
        WF = class<InstantFire>(class<WeaponDamageType>(DamageType).default.WeaponClass.default.FireModeClass[i]);
        if(WF != None && WF.default.DamageType == DamageType)
        {
            foreach Injured.CollidingActors(class'Actor', Victims, DamageRadius, HitLocation)
            {
                if(
                    Victims != Injured
                    && FluidSurfaceInfo(Victims) == None
                    && Injured.FastTrace(Injured.Location, Victims.Location)
                )
                {
                    dir = Victims.Location - HitLocation;
                    dist = FMax(1, VSize(dir));
                    dir = dir / dist;
                    damageScale = 1 - FMax(0, (dist - Victims.CollisionRadius) / DamageRadius);
                    Victims.TakeDamage
                    (
                        damageScale * OriginalDamage,
                        Instigator,
                        Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                        (damageScale * VSize(Momentum) * dir),
                        MyDamageType
                    );
                    if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                    {
                        Vehicle(Victims).DriverRadiusDamage(
                            OriginalDamage,
                            DamageRadius,
                            Instigator.Controller,
                            MyDamageType,
                            VSize(Momentum),
                            HitLocation
                        );
                    }
                }
            }
            return;
        }
    }
}

function RPGTick(float dt)
{
    local Projectile Proj;

    foreach Instigator.CollidingActors(class'Projectile', Proj, 256)
    {
        if(
            Proj.Instigator == Instigator
            && !bool(int(string(Proj.Tag)) & F_PROJMOD_EXPLOSIVE)
            && Instigator.FastTrace(Instigator.Location, Proj.Location)
        )
        {
            Proj.SetPropertyText("Tag", string(int(string(Proj.Tag)) | F_PROJMOD_EXPLOSIVE));

            Proj.DamageRadius *= 1.0f + BonusPerLevel * float(Modifier);
        }
    }
}

defaultproperties
{
    MyDamageType=class'DamTypeAugmentExplosive'
    DefaultDamageRadius=220.0
    MaxLevel=10
    BonusPerLevel=0.02
    ModifierName="Explosive"
    Description="$1 splash damage"
    LongDescription="Adds $1 splash damage per level. This will also apply for instant hit weapons."
    IconMaterial=Texture'TURRPG2.WOPIcons.NukeBombIcon'
    ModifierOverlay=Shader'WOPWeapons.DamageShader'
    ModifierColor=(R=255,G=192)
}
