//=============================================================================
// ArtificerAugment_Explosive.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Explosive extends ArtificerAugmentBase_ProjectileMod;

var() class<DamageType> MyDamageType;
var() float DefaultDamageRadius;
var float DamageRadius;

function SetLevel(int NewLevel)
{
    Super.SetLevel(NewLevel);
    DamageRadius = DefaultDamageRadius * (1.0f + BonusPerLevel * float(Modifier));
}

function vector FindHitLocation(InstantFire WF)
{
    /*
    local vector Start;
    local vector Aim;
    local vector HitLocation, HitNormal;
    local class<Actor> DesiredClass;
    local Actor A;

    Start = Instigator.Location + Instigator.EyePosition();
    Aim = Weapon.AdjustAim(StartTrace, AimError);
    End = Start + WF.TraceRange * vector(Aim);

    if(WF.Spread > 0)
    {
        switch(WF.Class)
        {
            case class'AssaultFire':
            case class'MinigunFire':
            case class'MinigunAltFire':
                return WeaponAttachment(WF.Weapon.ThirdPersonActor).mHitLocation;
            case 'ShockBeamFire':
                DesiredClass = class'XWeapons.ShockBeamEffect';
                break;
            case 'SniperFire':
                DesiredClass = class'XWeapons.NewLightningBolt';
                break;
            case 'ClassicSniperFire':
                DesiredClass = class'TracerProjectile';
                break;
        }

        foreach Instigator.RadiusActors(DesiredClass, A, Instigator.CollisionRadius, StartTrace)
        {
            if(A.Instigator == Instigator)
            {
                if(ClassIsChildOf(A.Class, class'xEmitter'))
                    return xEmitter(A).mSpawnVecA;
                if(A.Class == class'TracerProjectile')
                {
                    A = Weapon.Trace(HitLocation, HitNormal, Start + WF.TraceRange * vector(A.Rotation), Start, true);
                    if(HitLocation != vect(0, 0, 0))
                        return HitLocation;
                    else
                        return End;
                }

                // TODO figure out what to do with others
                return vect(0, 0, 0);
            }
        }
    }
    */

    return vect(0, 0, 0);
}

function WeaponFire(byte Mode)
{
    local InstantFire WF;
    local float damageScale, dist;
    local vector HitLocation;
    local vector dir;
    local Actor Victims;

    WF = InstantFire(Weapon.GetFireMode(Mode));
    if(WF == None)
        return;

    HitLocation = FindHitLocation(WF);
    if(HitLocation == vect(0, 0, 0))
        return;

    foreach Weapon.CollidingActors(class'Actor', Victims, DamageRadius, HitLocation)
    {
        if(
            Victims != Instigator
            && FluidSurfaceInfo(Victims) == None
            && Victims.FastTrace(HitLocation, Victims.Location)
        )
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1, VSize(dir));
            dir = dir / dist;
            damageScale = 1 - FMax(0, (dist - Victims.CollisionRadius) / DamageRadius);
            Victims.TakeDamage
            (
                damageScale * (WF.DamageMin + WF.DamageMax) * 0.5,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                (damageScale * WF.Momentum * dir),
                MyDamageType
            );
            if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
            {
                Vehicle(Victims).DriverRadiusDamage(
                    WF.DamageMin * WF.DamageMax * 0.5,
                    DamageRadius,
                    Instigator.Controller,
                    MyDamageType,
                    WF.Momentum,
                    HitLocation
                );
            }
        }
    }
}

function ModifyProjectile(Projectile Proj)
{
    local vector ClientLocation;
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;

    Proj.DamageRadius *= 1.0f + BonusPerLevel * float(Modifier);

    ClientLocation = Proj.Location + Proj.Velocity * 0.05f;
    if(Proj.Physics == PHYS_Falling)
        ClientLocation += vect(0, 0, -0.00125f) * Proj.Level.DefaultGravity;

    for(C = Proj.Level.ControllerList; C != None; C = C.NextController)
    {
        if(PlayerController(C) != None)
        {
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
            if(RPRI != None)
            {
                RPRI.ClientSyncProjectile(
                    ClientLocation,
                    Proj.Class,
                    Proj.Instigator,
                    1.0f + BonusPerLevel * float(Modifier),
                    F_PROJMOD_EXPLOSIVE
                );
            }
        }
    }
}

defaultproperties
{
    ModFlag=F_PROJMOD_EXPLOSIVE
    MyDamageType=class'DamTypeAugmentExplosive'
    DefaultDamageRadius=220.0
    MaxLevel=5
    BonusPerLevel=0.2
    ModifierName="Explosive"
    Description="$1 splash damage"
    LongDescription="Adds $1 splash damage per level. This will also apply for instant hit weapons."
    IconMaterial=Texture'TURRPG2.WOPIcons.NukeBombIcon'
    ModifierOverlay=Combiner'WOPWeapons.ExplosiveShader'
    ModifierColor=(R=255,G=192)
}
