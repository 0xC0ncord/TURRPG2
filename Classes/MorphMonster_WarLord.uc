//=============================================================================
// MorphMonster_WarLord.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Warlord extends MorphMonster;

var bool bRocketDir;
var bool bSeeking;

function bool IsFlying()
{
    return (Physics==PHYS_Flying || (Controller!=None && Controller.IsInState('PlayerFlying')) || GetAnimSequence()=='Fly' || GetAnimSequence()=='FlyFire');
}

simulated function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local vector X,Y,Z,duckdir;

    GetAxes(Rotation,X,Y,Z);
    if (DoubleClickMove == DCLICK_Forward)
        duckdir = X;
    else if (DoubleClickMove == DCLICK_Back)
        duckdir = -1*X;
    else if (DoubleClickMove == DCLICK_Left)
        duckdir = -1*Y;
    else if (DoubleClickMove == DCLICK_Right)
        duckdir = Y;

    SetPhysics(PHYS_Flying);
    if(PlayerController(Controller)!=None)
        Controller.GotoState('PlayerFlying');
    if ( !bShotAnim && (FRand() < 0.3))
    {
        bShotAnim = true;
        SetAnimAction('FDodgeUp');
    }
    Velocity = AirSpeed * duckDir;
    return true;
}

function FireProjectile()
{
    local vector FireStart,X,Y,Z;
    local rotator ProjRot;
    local SeekingRocketProj S;

    if ( Controller != None )
    {
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
        ProjRot = Controller.AdjustAim(SavedFireProperties,FireStart,600);

        // Vary bRocketDir Yaw to prevent an Enemy "sweet spot" at about 768 UU ahead of the Warlord.
        // Vary Pitch as well.
        if(bSeeking)
        {
            if ( bRocketDir )
                ProjRot.Yaw += FRand() * 1536;
            else
                ProjRot.Yaw -= FRand() * 1536;
            ProjRot.Pitch += ( FRand() * 500 ) - 500;
        }
        else
        {
            if ( bRocketDir )
                ProjRot.Yaw += FRand() * 128;
            else
                ProjRot.Yaw -= FRand() * 128;
            ProjRot.Pitch += ( FRand() * 125 ) - 125;
        }
        bRocketDir = !bRocketDir;
        S = Spawn(class'WarlordRocket',,,FireStart,ProjRot);
        if(bSeeking)
            S.Seeking = Controller.Enemy;
        PlaySound(FireSound,SLOT_Interact);
    }
}

//broken
function ChangePhysics(bool bNowFlying)
{
    if(bShotAnim)
        return;
    if(bNowFlying)
    {
        Controller.GotoState('PlayerFlying');
        SetPhysics(PHYS_Flying);
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        SetAnimAction('FDodgeUp');
    }
    if(!bNowFlying)
    {
        Controller.GotoState('PlayerWalking');
        SetPhysics(PHYS_Falling);
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        SetAnimAction('Land');
    }
}

function ChangeHoming()
{
    bSeeking=!bSeeking;
    if(bSeeking)
        PlaySound(sound'LockOn',SLOT_Interact);
    else
        PlaySound(sound'SeekLost',SLOT_Interact);
}

function PlayVictory()
{
    Controller.GotoState('PlayerWalking');
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlaySound(sound'laugh1WL',SLOT_Interact);
    SetAnimAction('Laugh');
}

function ProcessAttack(byte Mode)
{
    if(Mode==0)
        RangedAttack(Controller.Target);
    if(Mode==1)
        ChangeHoming();
    if(Mode==2)
    {
        bIgnoreFlyTime = Level.TimeSeconds+1;
        ChangePhysics(!IsFlying());
    }
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = (FRand() < 0.5);
}

function Step()
{
    PlaySound(sound'step1t', SLOT_Interact);
}

function Flap()
{
    PlaySound(sound'fly1WL', SLOT_Interact);
}

event Landed(vector HitNormal)
{
    SetPhysics(PHYS_Walking);
    Super.Landed(HitNormal);
}

event HitWall( vector HitNormal, actor HitWall )
{
    if ( HitNormal.Z > MINFLOORZ )
        SetPhysics(PHYS_Walking);
    Super.HitWall(HitNormal,HitWall);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    if ( Physics == PHYS_Flying )
        PlayAnim('Dead2A');
    else
        PlayAnim('Dead1');
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 )
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local name Anim;
    local float frame,rate;

    if ( bShotAnim )
        return;

    GetAnimParams(0, Anim,frame,rate);

    if ( Anim == 'FDodgeUp' )
        return;
    TweenAnim('TakeHit', 0.05);
}

function RangedAttack(Actor A)
{
    if ( bShotAnim )
        return;

    if ( Physics == PHYS_Flying )
        SetAnimAction('FlyFire');
    else if ( A!=None && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        SetAnimAction('Strike');
        if ( MeleeDamageTarget(45, (45000.0 * Normal(Controller.Target.Location - Location))) )
            PlaySound(sound'Threat1WL', SLOT_Talk);
    }
    else
    {
        SetAnimAction('Fire');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    bShotAnim = true;
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}

simulated function PlayFlying( bool bIsMoving )
{
    if( bIsMoving )
        LoopAnim('Fly', -1.0/AirSpeed,0.2, 0.4);
    else LoopAnim('Fly', 0.6,0.2);
}
simulated function PlayWaiting()
{
    PlaySound(sound'breath1WL', SLOT_Interact);
    LoopAnim('Idle_Rest',,0.2);
}
simulated function PlayWalking()
{
    LoopAnim('WalkF', -1.4/GroundSpeed,0.2, 0.4);
}
simulated function PlayRunning( byte MovementDir )
{
    LoopAnim('RunF', -1.0/GroundSpeed,0.2, 0.4);
}
simulated function PlayInAir()
{
    PlayFlying(False);
}
simulated function PlayLandingAnimation(float ImpactVel)
{
    PlayAnim('Land');
}
simulated function PlaySwimming()
{
    PlayFlying(False);
}

defaultproperties
{
     TauntAnimNames(1)="Twirl"
     TauntAnimNames(2)="Kick 1"
     TauntAnimNames(3)="Kick 2"
     TauntAnimNames(4)="Punch 1"
     TauntAnimNames(5)="Punch 2"
     TauntAnimNames(6)="Grab"
     TauntAnimNames(7)="Munch"
     TauntAnimNames(8)="Point"
     TauntAnims(1)="Twirl"
     TauntAnims(2)="GKick1"
     TauntAnims(3)="GKick2"
     TauntAnims(4)="GPunch1"
     TauntAnims(5)="GPunch2"
     TauntAnims(6)="Grab"
     TauntAnims(7)="Munch"
     TauntAnims(8)="Point"
     FireAnims(0)="FlyFire"
     FireAnims(1)="Strike"
     FireAnims(2)="Fire"
     bSeeking=True
     bMeleeFighter=False
     bTryToWalk=True
     bBoss=True
     DodgeSkillAdjust=4.000000
     HitSound(0)=Sound'SkaarjPack_rc.WarLord.injur1WL'
     HitSound(1)=Sound'SkaarjPack_rc.WarLord.injur2WL'
     HitSound(2)=Sound'SkaarjPack_rc.WarLord.injur1WL'
     HitSound(3)=Sound'SkaarjPack_rc.WarLord.injur2WL'
     DeathSound(0)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     DeathSound(1)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     DeathSound(2)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     DeathSound(3)=Sound'SkaarjPack_rc.WarLord.DeathCry1WL'
     ChallengeSound(0)=Sound'SkaarjPack_rc.WarLord.acquire1WL'
     ChallengeSound(1)=Sound'SkaarjPack_rc.WarLord.roam1WL'
     ChallengeSound(2)=Sound'SkaarjPack_rc.WarLord.threat1WL'
     ChallengeSound(3)=Sound'SkaarjPack_rc.WarLord.breath1WL'
     FireSound=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     AmmunitionClass=Class'SkaarjPack.WarlordAmmo'
     ScoringValue=10
     bCanFly=True
     MeleeRange=80.000000
     GroundSpeed=400.000000
     AirSpeed=500.000000
     Health=500
     MovementAnims(1)="RunF"
     MovementAnims(2)="RunF"
     MovementAnims(3)="RunF"
     TurnLeftAnim="Idle_Rest"
     TurnRightAnim="Idle_Rest"
     WalkAnims(1)="WalkF"
     WalkAnims(2)="WalkF"
     WalkAnims(3)="WalkF"
     AirAnims(0)="Fly"
     AirAnims(1)="Fly"
     AirAnims(2)="Fly"
     AirAnims(3)="Fly"
     TakeoffAnims(0)="Fly"
     TakeoffAnims(1)="Fly"
     TakeoffAnims(2)="Fly"
     TakeoffAnims(3)="Fly"
     AirStillAnim="Fly"
     TakeoffStillAnim="Fly"
     Mesh=VertMesh'SkaarjPack_rc.WarlordM'
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.JWarlord1'
     Skins(1)=FinalBlend'SkaarjPackSkins.Skins.JWarlord1'
     TransientSoundVolume=1.000000
     TransientSoundRadius=1500.000000
     CollisionRadius=47.000000
     CollisionHeight=78.000000
     Mass=300.000000
}
