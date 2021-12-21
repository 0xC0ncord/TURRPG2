//=============================================================================
// MorphMonster_Skaarj.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Skaarj extends MorphMonster;

var sound FootStep[2];
var name DeathAnim[4];

function PlayVictory()
{
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlaySound(sound'hairflp2sk',SLOT_Interact);
    SetAnimAction('HairFlip');
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.9 * CollisionRadius * X + 0.9 * CollisionRadius * Y + 0.4 * CollisionHeight * Z;
}

function SpawnTwoShots()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;

    GetAxes(Rotation,X,Y,Z);
    FireStart = GetFireStart(X,Y,Z);
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
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);

    FireStart = FireStart - 1.8 * CollisionRadius * Y;
    FireRotation.Yaw += 400;
    spawn(MyAmmo.ProjectileClass,,,FireStart, FireRotation);
}

simulated function AnimEnd(int Channel)
{
    local name Anim;
    local float frame,rate;

    if ( Channel == 0 )
    {
        GetAnimParams(0, Anim,frame,rate);
        if ( Anim == 'looking' )
            IdleWeaponAnim = 'guncheck';
        else if ( (Anim == 'guncheck') && (FRand() < 0.5) )
            IdleWeaponAnim = 'looking';
    }
    Super.AnimEnd(Channel);
}

function RunStep()
{
    PlaySound(FootStep[Rand(2)], SLOT_Interact);
}

function WalkStep()
{
    PlaySound(FootStep[Rand(2)], SLOT_Interact,0.2);
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
        PlayAnim('Death5',1,0.05);
        CreateGib('head',DamageType,Rotation);
        return;
    }
    if ( Velocity.Z > 300 )
    {
        if ( FRand() < 0.5 )
            PlayAnim('Death',1.2,0.05);
        else
            PlayAnim('Death2',1.2,0.05);
        return;
    }
    PlayAnim(DeathAnim[Rand(4)],1.2,0.05);
}

function SpinDamageTarget()
{
    if (MeleeDamageTarget(20, (30000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'clawhit1s', SLOT_Interact);
}

function ClawDamageTarget()
{
    if ( MeleeDamageTarget(25, (25000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'clawhit1s', SLOT_Interact);
}

function RangedAttack(Actor A)
{
    local name Anim;
    local float frame,rate;

    if ( bShotAnim )
        return;
    bShotAnim = true;
    if ( Physics == PHYS_Swimming )
        SetAnimAction('SwimFire');
    else if ( A!=None && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        if ( FRand() < 0.7 )
        {
            SetAnimAction('Spin');
            PlaySound(sound'Spin1s', SLOT_Interact);
            Acceleration = AccelRate * Normal(A.Location - Location);
            return;
        }
        SetAnimAction('Claw');
        PlaySound(sound'Claw2s', SLOT_Interact);
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else if ( Velocity == vect(0,0,0) )
    {
        SetAnimAction('Firing');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else
    {
        GetAnimParams(0,Anim,frame,rate);
        if ( Anim == 'RunL' || Anim == 'StrafeLeftFr')
            SetAnimAction('StrafeLeftFr');
        else if ( Anim == 'RunR' || Anim == 'StrafeRightFr')
            SetAnimAction('StrafeRightFr');
        else
            SetAnimAction('JogFire');
    }
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
    AnimSequence = LastUsedAnim;
    if (AnimSequence == 'Breath')
    {
        PlayAnim('Breath2',,0.2);
    }
    else
    {
        if (decision < 0.2)
        {
            PlayAnim('Breath',,0.2);
        }
        else PlayAnim('Breath2',,0.2);
    }
}
simulated function PlayWalking()
{
    LoopAnim('WalkF', 0.88,0.2);
}
simulated function PlayRunning( byte MovementDir )
{
    if( MovementDir==0 || MovementDir==1 )
        LoopAnim('RunF',-1.0/GroundSpeed,0.1, 0.5);
    else if( MovementDir==2 )
        LoopAnim('RunL',-2.5/GroundSpeed,0.1, 1.0);
    else LoopAnim('RunR',-2.5/GroundSpeed,0.1, 1.0);
}
simulated function PlayInAir()
{
    PlayAnim('Jump2',0.4,0.2);
}
simulated function PlayLandingAnimation(float ImpactVel)
{
    if( impactVel > 1.7 * JumpZ )
        TweenAnim('Landed',0.1);
    else TweenAnim('Land', 0.1);
}
simulated function PlaySwimming()
{
    PlayAnim('Swim',0.4,0.2);
}

defaultproperties
{
     TauntAnimNames(1)="Button 1"
     TauntAnimNames(2)="Button 2"
     TauntAnimNames(3)="Button 3"
     TauntAnimNames(4)="Button 4"
     TauntAnimNames(5)="Button 5"
     TauntAnimNames(6)="Multi-Button 1"
     TauntAnimNames(7)="Multi-Button 2"
     TauntAnimNames(8)="Multi-Button 3"
     TauntAnimNames(9)="Multi-Button 4"
     TauntAnimNames(10)="Looking"
     TauntAnimNames(11)="Check Gun"
     TauntAnimNames(12)="Fix Gun"
     TauntAnimNames(13)="Stretch"
     TauntAnims(1)="Button1"
     TauntAnims(2)="Button2"
     TauntAnims(3)="Button3"
     TauntAnims(4)="Button4"
     TauntAnims(5)="Button5"
     TauntAnims(6)="MButton1"
     TauntAnims(7)="MButton2"
     TauntAnims(8)="MButton3"
     TauntAnims(9)="MButton4"
     TauntAnims(10)="Looking"
     TauntAnims(11)="guncheck"
     TauntAnims(12)="gunfix"
     TauntAnims(13)="Stretch"
     FireAnims(0)="SwimFire"
     FireAnims(1)="Spin"
     FireAnims(2)="Claw"
     FireAnims(3)="Firing"
     FireAnims(4)="StrafeLeftFr"
     FireAnims(5)="StrafeRightFr"
     FireAnims(6)="JogFire"
     bCheckMovingDir=True
     Footstep(0)=Sound'SkaarjPack_rc.Cow.walkC'
     Footstep(1)=Sound'SkaarjPack_rc.Cow.walkC'
     DeathAnim(0)="Death"
     DeathAnim(1)="Death2"
     DeathAnim(2)="Death3"
     DeathAnim(3)="Death4"
     HitSound(0)=Sound'SkaarjPack_rc.Skaarj.injur1sk'
     HitSound(1)=Sound'SkaarjPack_rc.Skaarj.injur2sk'
     HitSound(2)=Sound'SkaarjPack_rc.Skaarj.injur3sk'
     HitSound(3)=Sound'SkaarjPack_rc.Skaarj.injur3sk'
     DeathSound(0)=Sound'SkaarjPack_rc.Skaarj.death1sk'
     DeathSound(1)=Sound'SkaarjPack_rc.Skaarj.death2sk'
     ChallengeSound(0)=Sound'SkaarjPack_rc.Skaarj.chalnge1s'
     ChallengeSound(1)=Sound'SkaarjPack_rc.Skaarj.chalnge3s'
     ChallengeSound(2)=Sound'SkaarjPack_rc.Skaarj.roam11s'
     ChallengeSound(3)=Sound'SkaarjPack_rc.Skaarj.roam11s'
     AmmunitionClass=Class'SkaarjPack.SkaarjAmmo'
     ScoringValue=6
     IdleHeavyAnim="Idle_Biggun"
     IdleRifleAnim="Idle_Rifle"
     MeleeRange=60.000000
     JumpZ=550.000000
     Health=150
     MovementAnims(1)="RunR"
     MovementAnims(2)="RunR"
     MovementAnims(3)="RunL"
     SwimAnims(0)="Swim"
     SwimAnims(1)="Swim"
     SwimAnims(2)="Swim"
     SwimAnims(3)="Swim"
     WalkAnims(1)="WalkF"
     WalkAnims(2)="WalkF"
     WalkAnims(3)="WalkF"
     AirAnims(0)="InAir"
     AirAnims(1)="InAir"
     AirAnims(2)="InAir"
     AirAnims(3)="InAir"
     LandAnims(0)="Landed"
     LandAnims(1)="Landed"
     LandAnims(2)="Landed"
     LandAnims(3)="Landed"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeB"
     DodgeAnims(2)="DodgeR"
     DodgeAnims(3)="DodgeL"
     AirStillAnim="Jump2"
     TakeoffStillAnim="Jump2"
     IdleSwimAnim="Swim"
     IdleWeaponAnim="Looking"
     IdleRestAnim="Breath"
     Mesh=VertMesh'SkaarjPack_rc.Skaarjw'
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.Skaarjw1'
     Mass=150.000000
     Buoyancy=150.000000
     RotationRate=(Yaw=60000)
}
