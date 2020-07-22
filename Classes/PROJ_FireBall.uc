//=============================================================================
// PROJ_FireBall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class PROJ_FireBall extends Projectile;

var FX_FireBall FireBallEffect;
var xEmitter SmokeTrail;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    if( Pawn(Owner) != None )
        Instigator = Pawn( Owner );
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
    {
        FireBallEffect = Spawn(class'FX_FireBall', self);
        FireBallEffect.SetBase(self);
        SmokeTrail = Spawn(class'BelchFlames',self);
    }

    Velocity = Speed * Vector(Rotation);

    SetTimer(0.4, false);
}

simulated function PostNetBeginPlay()
{
    local PlayerController PC;

    Super.PostNetBeginPlay();

    if ( Level.NetMode == NM_DedicatedServer )
        return;

    PC = Level.GetLocalPlayerController();
    if ( (Instigator != None) && (PC == Instigator.Controller) )
        return;
    if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
    {
        bDynamicLight = false;
        LightType = LT_None;
    }
    else if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
    {
        bDynamicLight = false;
        LightType = LT_None;
    }
}

function Timer()
{
    SetCollisionSize(20, 20);
}

simulated function Destroyed()
{
    if (FireBallEffect != None)
    {
        if ( bNoFX )
            FireBallEffect.Destroy();
        else
            FireBallEffect.Kill();
    }
    if ( SmokeTrail != None )
        SmokeTrail.mRegen = False;
    Super.Destroyed();
}

simulated function DestroyTrails()
{
    if (FireBallEffect != None)
        FireBallEffect.Destroy();
}

simulated function Landed( vector HitNormal )
{
    Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if ( (Other != instigator) && (Projectile(Other)==None || Other.bProjTarget) )
        Explode(HitLocation,Normal(HitLocation-Other.Location));
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;
    local bool VictimPawn;

    if ( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && FluidSurfaceInfo(Victims)==None && FastTrace(Location,Victims.Location))
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
            if ( Instigator == None || Instigator.Controller == None )
                Victims.SetDelayedDamageInstigatorController( InstigatorController );
            if ( Victims == LastTouched )
                LastTouched = None;
            VictimPawn = false;
            if (Pawn(Victims) != None)
            {
                VictimPawn = true;
            }
            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                (damageScale * Momentum * dir),
                DamageType
            );
            if (Victims != None)
            {
                if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                    Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
            }

        }
    }
    if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && FluidSurfaceInfo(LastTouched)==None )
    {
        Victims = LastTouched;
        LastTouched = None;
        dir = Victims.Location - HitLocation;
        dist = FMax(1,VSize(dir));
        dir = dir/dist;
        damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
        if ( Instigator == None || Instigator.Controller == None )
            Victims.SetDelayedDamageInstigatorController(InstigatorController);
        VictimPawn = false;
        if (Pawn(Victims) != None)
        {
            VictimPawn = true;
        }
        Victims.TakeDamage
        (
            damageScale * DamageAmount,
            Instigator,
            Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
            (damageScale * Momentum * dir),
            DamageType
        );
        if (Victims != None)
        {
            if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
        }
    }

    bHurtEntry = false;
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    local PlayerController PC;

    PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'NewExplosionA',,,HitLocation + HitNormal*20,rotator(HitNormal));
        PC = Level.GetLocalPlayerController();
        if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
            Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
    }
    if ( Role == ROLE_Authority )
    {
        HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    }
    SetCollisionSize(0.0, 0.0);
    Destroy();
}

defaultproperties
{
     Speed=3500.000000
     MaxSpeed=4000.000000
     bSwitchToZeroCollision=True
     Damage=200.000000
     MomentumTransfer=70000.000000
     MyDamageType=Class'DamTypeFireBall'
     ImpactSound=Sound'WeaponSounds.ShockRifle.ShockRifleExplosion'
     ExplosionDecal=Class'XEffects.RocketMark'
     MaxEffectDistance=7000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=195
     LightSaturation=85
     LightBrightness=255.000000
     LightRadius=4.000000
     DrawType=DT_Sprite
     CullDistance=4000.000000
     bDynamicLight=True
     bOnlyDirtyReplication=True
     AmbientSound=Sound'WeaponSounds.ShockRifle.ShockRifleProjectile'
     LifeSpan=10.000000
     Texture=Texture'AW-2004Particles.Fire.NapalmSpot'
     DrawScale=0.150000
     Skins(0)=Texture'XEffects.Skins.MuzFlashWhite_t'
     Style=STY_Translucent
     FluidSurfaceShootStrengthMod=8.000000
     SoundVolume=50
     SoundRadius=100.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bProjTarget=True
     bAlwaysFaceCamera=True
     ForceType=FT_Constant
     ForceRadius=40.000000
     ForceScale=5.000000
}
