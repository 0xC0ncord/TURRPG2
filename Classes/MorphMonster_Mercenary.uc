//=============================================================================
// MorphMonster_Mercenary.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Mercenary extends MorphMonster_SMPMonster;

var name DeathAnim[4];
var byte sprayoffset;

var()   class<xEmitter> FlashEmitterClass;
var()   xEmitter FlashEmitter;
var()   class<xEmitter> SmokeEmitterClass;
var()   xEmitter SmokeEmitter;
var float Momentum;
var float TraceRange;
var class<DamageType>  MyDamageType;
var class<xEmitter>     mTracerClass;
var xEmitter            mTracer;
var float               mTracerFreq;
var float               mTracerLen;
var float               mLastTracerTime;
var vector              mHitLocation,mHitNormal;
var rotator             mHitRot;
var float               mTracerUpdateTime;
var() int SprayDamage,SprayDamageMax;

var FireProperties RocketFireProperties;

var class<Ammunition> RocketAmmoClass;
var Ammunition RocketAmmo;

var() int PunchDamage;
var() sound Punch;
var() sound PunchHit;
var() sound Flip;
var() sound CheckWeapon;
var() sound WeaponSpray;
var() sound syllable1;
var() sound syllable2;
var() sound syllable3;
var() sound syllable4;
var() sound syllable5;
var() sound syllable6;
var() sound breath;
var() sound footstep1;
var() bool bUseSeekingRocket;

replication
{
    unreliable if(Role == ROLE_Authority)
        mHitLocation,mHitNormal;
}

function RangedAttack(Actor A)
{
    local float decision;

    if ( bShotAnim )
        return;
    bShotAnim=true;
    decision = FRand();

    if ( Physics == PHYS_Swimming )
        SetAnimAction('SwimFire');
    else if ( A!=None && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        if(GetAnimSequence()=='Swat')
            decision += 0.2;

        if ( decision < 0.5 )
        {
            SetAnimAction('Swat');
        }
        else
        {
            SetAnimAction('Punch');
        }
        PlaySound(Punch, SLOT_Interact);
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else if ( Velocity == vect(0,0,0) )
    {
        sprayoffset = 0;
        PlaySound(WeaponSpray, SLOT_Interact);
        SetAnimAction('Spray');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else
    {
        sprayoffset = 0;
        PlaySound(WeaponSpray, SLOT_Interact);
        SetAnimAction('WalkSpray');
    }
}

function FireRocket(Actor A)
{
    local float decision;

    if ( bShotAnim )
        return;
    bShotAnim=true;
    decision=FRand();

    if ( Physics == PHYS_Swimming )
        SetAnimAction('SwimFire');
    else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        if(GetAnimSequence()=='Swat')
            decision += 0.2;

        if ( decision < 0.5 )
        {
            SetAnimAction('Swat');
        }
        else
        {
            SetAnimAction('Punch');
        }
        PlaySound(Punch, SLOT_Interact);
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else if ( Velocity == vect(0,0,0) )
    {
        SetAnimAction('Shoot');
        SpawnRocket();
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else
    {
        SetAnimAction('WalkFire');
    }
}

function ProcessAttack(byte Mode)
{
    if(Mode==0)
        RangedAttack(Controller.Target);
    if(Mode==1)
        FireRocket(Controller.Target);
}

event PostBeginPlay()
{
    local Sound S;

    Super.PostBeginPlay();
    RocketAmmo=spawn(RocketAmmoClass);

    S=Sound(DynamicLoadObject("U1Pawns.Mercenary.chlng2mr",Class'Sound'));
    if(S!=None)
        TauntSounds[9]=S;
    S=Sound(DynamicLoadObject("U1Pawns.Mercenary.chlng3mr",Class'Sound'));
    if(S!=None)
        TauntSounds[9]=S;
    S=Sound(DynamicLoadObject("U1Pawns.Mercenary.chlng3mr",Class'Sound'));
    if(S!=None)
        TauntSounds[9]=S;
    S=Sound(DynamicLoadObject("U1Pawns.Mercenary.weapon1mr",Class'Sound'));
    if(S!=None)
        TauntSounds[9]=S;
}

function PlayVictory()
{
    if(Controller==none) return;
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlaySound(Flip, SLOT_Interact);
    SetAnimAction('Jump');
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    // random
    if ( VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
        PlayAnim('GutHit',, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
      //  PlayAnim('Hit',, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim('RightHit',, 0.1);
    }
    else
    {
        PlayAnim('LeftHit',, 0.1);
    }
}

function Step()
{
    PlaySound(footstep1, SLOT_Interact,,,1500);
}

function WalkStep()
{
    PlaySound(footstep1, SLOT_Interact,0.2,,500);
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    if ( sprayoffset >= 1 && sprayoffset <= 5 )
    {
        if ( GetAnimSequence() == 'Spray' )
            return Location + 1.25 * CollisionRadius * X - CollisionRadius * (0.2 * sprayoffset - 0.3) * Y;
        else
            return Location + 1.25 * CollisionRadius * X - CollisionRadius * (0.1 * sprayoffset - 0.1) * Y;
    }
    else
        return Location + 0.9 * CollisionRadius * X - 0.9 * CollisionRadius * Y;
}
simulated function SprayTarget()
{
    local rotator AdjRot;
    local Vector StartTrace;
    local vector RotX,RotY,RotZ;

    GetAxes(Rotation, RotX, RotY, RotZ);
    StartTrace = GetFireStart(RotX, RotY, RotZ); //ViewSpot;//Location;// + Instigator.EyePosition();
    if(Controller!=none)
    {
        if ( !SavedFireProperties.bInitialized )
        {
            SavedFireProperties.AmmoClass = MyAmmo.Class;
            SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
            SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
            SavedFireProperties.MaxRange = MyAmmo.MaxRange;
            SavedFireProperties.bTossed = MyAmmo.bTossed;
            SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
            SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
            SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
            SavedFireProperties.bInitialized = true;
        }

        AdjRot = Controller.AdjustAim(SavedFireProperties,StartTrace,600);
    }

    if ( GetAnimSequence() == 'Dead5' )
        AdjRot.Yaw += 1500 * (2 - sprayOffset);
    else
        AdjRot.Yaw += 500 * (3 - sprayOffset);
    sprayoffset++;

    if ( GetAnimSequence() == 'Dead5' )
        sprayoffset++;

    DoFireEffect();
    DoTrace(StartTrace,AdjRot);
}

simulated function InitEffects()
{
    local vector RotX,RotY,RotZ;
    local vector FireStartLoc;

    // don't even spawn on server
    if ( Level.NetMode == NM_DedicatedServer )
        return;
    GetAxes(Rotation, RotX, RotY, RotZ);
    FireStartLoc=GetFireStart(RotX, RotY, RotZ);

    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
        FlashEmitter = Spawn(FlashEmitterClass,,,FireStartLoc);

    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
        SmokeEmitter = Spawn(SmokeEmitterClass,,,FireStartLoc);
}


simulated   function DoFireEffect()
{
    MakeNoise(1.0);
    InitEffects();
    FlashMuzzleFlash();
    StartMuzzleSmoke();
}
simulated function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local int Damage;
    local Actor Other;
    local bool bDoReflect;
    local int ReflectNum;


    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        Other = Trace(HitLocation, HitNormal, End, Start, true);

        if ( Role == ROLE_Authority )
        {
            mHitLocation=HitLocation;
            mHitNormal=HitNormal;
        }


        Damage=SprayDamage+Rand(SprayDamageMax-SprayDamage);
        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (xPawn(Other)!=None && xPawn(Other).CheckReflect(HitLocation, RefNormal, Damage*0.25))
            {
                bDoReflect = true;
                HitNormal = Vect(0,0,0);
            }
            else  if (!Other.bWorldGeometry)
            {
                if(Level.NetMode != NM_Client)
                {
                Other.TakeDamage(Damage, self, HitLocation, Momentum*X, MyDamageType);
                HitNormal = Vect(0,0,0);
                }
            }
            else
            {
                SpawnHitEffect(Other, mHitLocation, mHitNormal);
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
        }

        UpdateTracer();

        if (bDoReflect && ++ReflectNum < 4)
        {
            Start = HitLocation;
            Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
    return;
}
simulated function UpdateTracer()
{
    local float len;
    local float invSpeed, hitDist;
    local Vector RotX,RotY,RotZ;
    local vector FireStart;

    if (Level.NetMode == NM_DedicatedServer)
        return;

    mTracerUpdateTime = Level.TimeSeconds;
    GetAxes(Rotation,RotX,RotY,RotZ);
    FireStart=GetFireStart(RotX,RotY,RotZ);
    mHitRot = rotator(mHitLocation - FireStart);

    if (mTracer == None)
        mTracer = Spawn(mTracerClass);

    if ( Level.bDropDetail || Level.DetailMode == DM_Low )
        mTracerFreq = 2 * Default.mTracerFreq;
    else
        mTracerFreq = Default.mTracerFreq;

    if (mTracer != None &&
        Level.TimeSeconds > mLastTracerTime + mTracerFreq)
    {
        mTracer.SetLocation(FireStart);
        mTracer.SetRotation(mHitRot);

        hitDist = VSize(mHitLocation - FireStart);

        len = mTracerLen * hitDist;
        invSpeed = 1.f / mTracer.mSpeedRange[1];

        mTracer.mLifeRange[0] = len * invSpeed;
        mTracer.mLifeRange[1] = mTracer.mLifeRange[0];
        mTracer.mSpawnVecB.Z = -1.f * (1.0-mTracerLen) * hitDist * invSpeed;
        mTracer.mStartParticles = 1;

        mLastTracerTime = Level.TimeSeconds;
    }
}
simulated function SpawnHitEffect(Actor Other, vector HitLocation, vector HitNormal)
{
    Spawn(class'HitEffect'.static.GetHitEffect(Other, HitLocation, HitNormal),,, HitLocation, Rotator(HitNormal));
}
simulated function FlashMuzzleFlash()
{
    local Vector RotX,RotY,RotZ;
    if (FlashEmitter != None)
    {
        GetAxes(Rotation,RotX,RotY,RotZ);
        FlashEmitter.SetLocation(GetFireStart(RotX, RotY, RotZ));
        FlashEmitter.SetRotation(Rotation);
        FlashEmitter.Trigger(self, self);
    }
}

simulated function StartMuzzleSmoke()
{
    local Vector RotX,RotY,RotZ;
    if ( !Level.bDropDetail && (SmokeEmitter != None) )
   {
        GetAxes(Rotation,RotX,RotY,RotZ);
        SmokeEmitter.SetLocation(GetFireStart(RotX, RotY, RotZ));
        SmokeEmitter.SetRotation(Rotation);
        SmokeEmitter.Trigger(self, self);
    }
}
function SpawnRocket()
{
    local vector RotX,RotY,RotZ,StartLoc;
    local SMPMercRocket R;

    GetAxes(Rotation, RotX, RotY, RotZ);
    StartLoc=GetFireStart(RotX, RotY, RotZ);
    if ( !RocketFireProperties.bInitialized )
    {
        RocketFireProperties.AmmoClass = RocketAmmo.Class;
        RocketFireProperties.ProjectileClass = RocketAmmo.default.ProjectileClass;
        RocketFireProperties.WarnTargetPct = RocketAmmo.WarnTargetPct;
        RocketFireProperties.MaxRange = RocketAmmo.MaxRange;
        RocketFireProperties.bTossed = RocketAmmo.bTossed;
        RocketFireProperties.bTrySplash = RocketAmmo.bTrySplash;
        RocketFireProperties.bLeadTarget = RocketAmmo.bLeadTarget;
        RocketFireProperties.bInstantHit = RocketAmmo.bInstantHit;
        RocketFireProperties.bInitialized = true;
    }

    R=SMPMercRocket(Spawn(RocketAmmo.ProjectileClass,,,StartLoc,Controller.AdjustAim(RocketFireProperties,StartLoc,600)));
    PlaySound(Sound'WeaponSounds.RocketLauncherFire');
    if(bUseSeekingRocket && R!=none)
    {
        R.Seeking = Controller.Enemy;
    }
}
function HitDamageTarget()
{
    if (MeleeDamageTarget(PunchDamage, (PunchDamage * 1000 * Normal(Controller.Target.Location - Location))))
        PlaySound(PunchHit, SLOT_Interact);
}
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    AmbientSound = None;
    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;
    LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetPhysics(PHYS_Falling);

    if ( (DamageType == class'DamTypeSniperHeadShot')
        || ((HitLoc.Z > Location.Z + 0.75 * CollisionHeight) && (FRand() > 0.5)
            && (DamageType != class'DamTypeAssaultBullet') && (DamageType != class'DamTypeMinigunBullet') && (DamageType != class'DamTypeFlakChunk')) )
    {
        PlayAnim('Dead5',1,0.05);
        CreateGib('head',DamageType,Rotation);
        return;
    }
    if ( Velocity.Z > 300 )
    {
        if ( FRand() < 0.6 )
            PlayAnim('Dead2',1.2,0.05);
        else
            PlayAnim('Death',1.2,0.05);
        return;
    }
    PlayAnim(DeathAnim[Rand(4)],1.2,0.05);
}

simulated function PlayFlying( bool bIsMoving )
{
    PlayInAir();
}
simulated function PlayWaiting()
{
    local float decision;
    local name AnimSequence;

    decision = FRand();
    AnimSequence = GetCurrentAnim();

    if ( (AnimSequence == 'Breath') && (decision < 0.15) )
    {
        LoopAnim('Weapon',,0.1);
    }
    else
        LoopAnim('Breath',,0.1);
}
simulated function PlayWalking()
{
    LoopAnim('Walk', 0.8,0.1);
}
simulated function PlayRunning( byte MovementDir )
{
    LoopAnim('Run', -1.0/GroundSpeed,0.1, 0.4);
}
simulated function PlayInAir()
{
    TweenAnim('Jump2', 0.1);
}
simulated function PlayLandingAnimation(float ImpactVel)
{
    TweenAnim('Land', 0.1);
}
simulated function PlaySwimming()
{
    LoopAnim('Swim', -1.0/GroundSpeed,0.1,0.3);
}

defaultproperties
{
    TauntAnimNames(1)="Button 1"
    TauntAnimNames(2)="Button 2"
    TauntAnimNames(3)="Button 3"
    TauntAnimNames(4)="Button 4"
    TauntAnimNames(5)="Multi-Button 1"
    TauntAnimNames(6)="Multi-Button 2"
    TauntAnimNames(7)="Multi-Button 3"
    TauntAnimNames(8)="Multi-Button 4"
    TauntAnimNames(9)="Talk 1"
    TauntAnimNames(10)="Talk 2"
    TauntAnimNames(11)="Talk 3"
    TauntAnimNames(12)="Weapon"
    TauntAnimNames(13)="Charge Up"
    TauntAnimNames(14)="Dance"
    TauntAnimNames(15)="Neck Crack"
    TauntAnims(1)="Button1"
    TauntAnims(2)="Button2"
    TauntAnims(3)="Button3"
    TauntAnims(4)="Button4"
    TauntAnims(5)="MButton1"
    TauntAnims(6)="MButton2"
    TauntAnims(7)="MButton3"
    TauntAnims(8)="MButton4"
    TauntAnims(9)="Talk1"
    TauntAnims(10)="Talk2"
    TauntAnims(11)="Talk3"
    TauntAnims(12)="Weapon"
    TauntAnims(13)="ChargeUp"
    TauntAnims(14)="Dance"
    TauntAnims(15)="NeckCrak"
    /*   TauntSounds(9)=Sound'U1Pawns.Mercenary.chlng2mr'
    TauntSounds(10)=Sound'U1Pawns.Mercenary.chlng3mr'
    TauntSounds(11)=Sound'U1Pawns.Mercenary.chlng3mr'
    TauntSounds(12)=Sound'U1Pawns.Mercenary.weapon1mr'*/
    FireAnims(0)="SwimFire"
    FireAnims(1)="Shoot"
    FireAnims(2)="WalkFire"
    FireAnims(3)="Spray"
    FireAnims(4)="WalkSpray"
    FireAnims(5)="Punch"
    FireAnims(6)="Swat"
    DeathAnim(0)="Death"
    DeathAnim(1)="Dead2"
    DeathAnim(2)="Dead3"
    DeathAnim(3)="Dead4"
    FlashEmitterClass=Class'XEffects.MinigunMuzFlash3rd'
    SmokeEmitterClass=Class'XEffects.MinigunMuzzleSmoke'
    TraceRange=10000.000000
    MyDamageType=Class'satoreMonsterPackv120.SMPMerceAmmoDamType'
    mTracerClass=Class'XEffects.Tracer'
    mTracerFreq=0.110000
    mTracerLen=0.800000
    SprayDamage=10
    SprayDamageMax=15
    RocketAmmoClass=Class'satoreMonsterPackv120.SMPMerceRocketAmmo'
    PunchDamage=20
    Punch=Sound'satoreMonsterPackSound.Mercenary.swat1mr'
    PunchHit=Sound'satoreMonsterPackSound.Mercenary.hit1mr'
    Flip=Sound'satoreMonsterPackSound.Mercenary.flip1mr'
    WeaponSpray=Sound'satoreMonsterPackSound.Mercenary.spray1mr'
    MonsterName="Mercenary"
    bCanDodge=False
    HitSound(0)=Sound'satoreMonsterPackSound.Mercenary.injur2mr'
    HitSound(1)=Sound'satoreMonsterPackSound.Mercenary.injur3mr'
    HitSound(2)=Sound'satoreMonsterPackSound.Mercenary.injur2mr'
    HitSound(3)=Sound'satoreMonsterPackSound.Mercenary.injur3mr'
    DeathSound(0)=Sound'satoreMonsterPackSound.Mercenary.death1mr'
    DeathSound(1)=Sound'satoreMonsterPackSound.Mercenary.death2mr'
    DeathSound(2)=Sound'satoreMonsterPackSound.Mercenary.death3mr'
    AmmunitionClass=Class'satoreMonsterPackv120.SMPMercenaryAmmo'
    ScoringValue=7
    MeleeRange=50.000000
    GroundSpeed=385.000000
    AirSpeed=300.000000
    AccelRate=800.000000
    Health=180
    MovementAnims(0)="Run"
    MovementAnims(1)="Run"
    MovementAnims(2)="Run"
    MovementAnims(3)="Run"
    TurnLeftAnim="Breath"
    TurnRightAnim="Breath"
    SwimAnims(0)="Swim"
    SwimAnims(1)="Swim"
    SwimAnims(2)="Swim"
    SwimAnims(3)="Swim"
    WalkAnims(0)="Walk"
    WalkAnims(1)="Walk"
    WalkAnims(2)="Walk"
    WalkAnims(3)="Walk"
    TakeoffAnims(0)="Breath"
    TakeoffAnims(1)="Breath"
    TakeoffAnims(2)="Breath"
    TakeoffAnims(3)="Breath"
    AirStillAnim="Jump2"
    TakeoffStillAnim="Breath"
    IdleCrouchAnim="Breath"
    IdleSwimAnim="Swim"
    IdleWeaponAnim="Breath"
    IdleRestAnim="Breath"
    AmbientSound=Sound'satoreMonsterPackSound.Mercenary.amb1mr'
    Mesh=VertMesh'satoreMonsterPackMeshes.Merc'
    Skins(0)=Texture'satoreMonsterPackTexture.Skins.JMerc1'
    Skins(1)=None
    CollisionRadius=35.000000
    CollisionHeight=48.000000
    Mass=150.000000
}
