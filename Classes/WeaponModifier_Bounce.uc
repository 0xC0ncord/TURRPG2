//=============================================================================
// WeaponModifier_Bounce.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Bounce extends RPGWeaponModifier;

var float ProjectileVelocityTreshold;

var Sound BounceSound;
var array<class<Projectile> > OldProjectileClasses;

var localized string BouncyText;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
    if(!Super.AllowedFor(Weapon, Other))
        return false;

    if(
        ClassIsChildOf(Weapon, class'RPGRocketLauncher') ||
        ClassIsChildOf(Weapon, class'LinkGun') ||
        ClassIsChildOf(Weapon, class'ShockRifle') ||
        ClassIsChildOf(Weapon, class'FlakCannon')
    )
    {
        return true;
    }

    return false;
}

static function vector ReflectVector(vector v, vector normal)
{
    return (v - 2.0 * normal * (v dot normal));
}

static function bool Bounce(Projectile P, vector HitNormal, Actor Wall)
{
    local vector NewVel;

    if(Wall == None || Volume(Wall) != None)
        return false;

    if(Wall.bStatic || Wall.bWorldGeometry || Mover(Wall) != None)
    {
        //abusing Actor.Buoyancy as bounciness - will never be used for projectiles anyway
        NewVel = P.Buoyancy * ReflectVector(P.Velocity, HitNormal);

        if(VSize(NewVel) > default.ProjectileVelocityTreshold)
        {
            //if this is a rocket, reset its timer so rockets shot in a spiral will not cause weird effects
            if(RocketProj(P) != None)
                P.SetTimer(0.0f, false);

            P.Velocity = NewVel;
            P.Acceleration = vect(0, 0, 0);
            P.SetRotation(rotator(NewVel));
            P.SetPhysics(P.default.Physics);

            if(default.BounceSound != None && !P.Level.bDropDetail)
                P.PlaySound(default.BounceSound);

            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}

function StartEffect()
{
    local WeaponFire WF;
    local int i;

    if(RPGRocketLauncher(Weapon) != None)
    {
        //fuck damnit, Epic...
        OldProjectileClasses[0] = RPGRocketLauncher(Weapon).RocketClass;
        RPGRocketLauncher(Weapon).RocketClass = class'PROJ_RocketBouncy';
    }
    else
    {
        for(i = 0; i < Weapon.NUM_FIRE_MODES; i++)
        {
            WF = Weapon.GetFireMode(i);
            if(WF != None)
            {
                OldProjectileClasses[i] = WF.ProjectileClass;

                if(ClassIsChildOf(WF.ProjectileClass, class'FlakShell'))
                    WF.ProjectileClass = class'PROJ_FlakShellBouncy';
                else if(ClassIsChildOf(WF.ProjectileClass, class'ShockProjectile'))
                    WF.ProjectileClass = class'PROJ_ShockBallBouncy';
                else if(ClassIsChildOf(WF.ProjectileClass, class'LinkProjectile'))
                    WF.ProjectileClass = class'PROJ_LinkPlasmaBouncy';
            }
            else
            {
                OldProjectileClasses[i] = None;
            }
        }
    }
}

function StopEffect()
{
    local WeaponFire WF;
    local int i;

    if(Weapon == None)
        return;

    if(OldProjectileClasses.Length > 0)
    {
        if(RPGRocketLauncher(Weapon) != None)
        {
            RPGRocketLauncher(Weapon).RocketClass = class<RocketProj>(OldProjectileClasses[0]);
        }
        else
        {
            for(i = 0; i < Weapon.NUM_FIRE_MODES && i < OldProjectileClasses.Length; i++)
            {
                WF = Weapon.GetFireMode(i);
                if(WF != None)
                    WF.ProjectileClass = OldProjectileClasses[i];
            }
        }
        OldProjectileClasses.Length = 0;
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(BouncyText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    StaticAddToDescription(Description, Modifier, default.BouncyText);

    return Description;
}

defaultproperties
{
    BouncyText="bouncy projectiles"

    ProjectileVelocityTreshold=500

    DamageBonus=0.04
    bCanHaveZeroModifier=True
    MinModifier=0
    MaxModifier=5
    ModifierOverlay=Combiner'BounceShader'
    BounceSound=Sound'TURRPG2.Effects.boing'
    PatternPos="Bouncy $W"
    //AI
    AIRatingBonus=0.00
}
