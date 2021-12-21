//=============================================================================
// MorphMonster_SkaarjTrooper.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_SkaarjTrooper extends MorphMonster_Skaarj;

var     float   duckTime;
var()       bool    bUseShield;
var() class<Projectile> ProjectileClass;
var()   bool                bTwoShot;
var bool Shielding;

var float LastAttackTime;
var() float smpRefireRate;

replication
{
    reliable if(Role==Role_Authority && bNetDirty)
        Shielding;
}

function RangedAttack(Actor A)
{
    local name Anim;
    local float frame,rate;

    smpRefireRate=default.smpRefireRate*FireAnimSpeed;

    if ( bShotAnim )
        return;
    bShotAnim = true;
    if ( A!=None && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
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
    else if(Level.TimeSeconds-LastAttackTime<smpRefireRate)
    {
        bShotAnim = false;
        return;
    }
    else if ( Velocity == vect(0,0,0) )
    {
        SetAnimAction('Firing');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        SpawnTwoShots();
    }
    else
    {
        GetAnimParams(0,Anim,frame,rate);
        if ( Anim == 'StrafeLeft' || Anim == 'StrafeLeftFr')
            SetAnimAction('StrafeLeftFr');
        else if ( Anim == 'StrafeRight' || Anim == 'StrafeRightFr')
            SetAnimAction('StrafeRightFr');
        else
            SetAnimAction('JogFire');
    }
}

state NewShldUp
{
    function RangedAttack(Actor A)
    {
        if ( bShotAnim )
            return;
        if(Level.TimeSeconds-LastAttackTime<smpRefireRate)
        {
            bShotAnim = false;
            return;
        }
        TweenAnim('ShldFire', 0.20);
        Acceleration = vect(0,0,0); //stop
        Controller.bPreparingMove = true;
        SpawnTwoShots();

        bShotAnim = true;
    }
    simulated function PlayDirectionalHit(Vector HitLoc);
    simulated function BeginState()
    {
        Acceleration = vect(0,0,0); //stop
        Controller.bPreparingMove = true;
        SetAnimAction('ShldUp');
        bShotAnim = true;
        smpRefireRate=1.7*FireAnimSpeed;
        Shielding=true;
    }
    simulated function EndState()
    {
        SetAnimAction('ShldDown');
        bShotAnim = true;
        smpRefireRate=default.smpRefireRate*FireAnimSpeed;
        Shielding=false;
    }
}

simulated function Tick( float DeltaTime )
{
    if(Shielding)
        Acceleration = vect(0,0,0);
    Super.Tick(DeltaTime);
}

function bool DoJump( bool bUpdating )
{
    if( Shielding )
        return false;
    return Super.DoJump(bUpdating);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    if ( Shielding )
        Return False;
    Return Super.Dodge(DoubleClickMove);
}

function PlayVictory()
{
    if(Controller==none) return;
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    SetAnimAction('Shield');
}

function DoShield(bool bShieldNow)
{
    if(bShieldNow)
        GotoState('NewShldUp');
    else
        GotoState('');
}

function ProcessAttack(byte Mode)
{
    if(Mode==0)
        RangedAttack(Controller.Target);
    if(Mode==1)
    {
        if(bShotAnim)
            return;
        if(Shielding)
            DoShield(False);
        else
            DoShield(True);
    }
}

function SpawnTwoShots()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;

    if(Role<Role_Authority)
        return;

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

    if(bTwoShot)
    {
        FireStart = FireStart - 1.8 * CollisionRadius * Y;
        FireRotation.Yaw += 400;
        spawn(MyAmmo.ProjectileClass,,,FireStart, FireRotation);
    }
    LastAttackTime=Level.TimeSeconds;
    NextFireTime=LastAttackTime+smpRefireRate;
}
function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
    local Vector HitDir;
    local Vector FaceDir;
    local rotator FaceRot;
    local name AnimName;
    AnimName=GetAnimSequence();
    if(AnimName!='ShldFire' && AnimName!='HoldShield' &&
        AnimName!='Shldland' && AnimName!='ShldTest' && AnimName!='ShldUp' && AnimName!='ShldDown' && AnimName!='Shield')
        return false;
    FaceRot=Rotation;
    if(AnimName=='ShldFire')
        FaceRot.Yaw+=10000;
    FaceDir=vector(FaceRot);
    HitDir = Normal(Location-HitLocation+ Vect(0,0,8));
    RefNormal=FaceDir;
    if ( FaceDir dot HitDir < -0.30 ) // 72 degree protection arc
        return true;
    return false;
}
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                    vector momentum, class<DamageType> damageType)
{
    local vector HitNormal;
    if(CheckReflect(HitLocation,HitNormal,Damage))
        damage*=0.2;
    super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.9 * CollisionRadius * X - 0.9 * CollisionRadius * Y + 0.2 * CollisionHeight * Z;
}
simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    if(Shielding)
        return;

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

    if ( Dir dot X > 0.7 || Dir == vect(0,0,0))
    {
        if((HitLoc.Z > Location.Z + 0.75 * CollisionHeight) && (FRand() > 0.5))
            PlayAnim('HeadHit',, 0.1);
        else
            PlayAnim('GutHit',, 0.1);
    }
    else if ( Dir dot X < -0.7 )
    {
        PlayAnim('GutHit',, 0.1);
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
simulated function AnimEnd(int Channel)
{
    Super.AnimEnd(Channel);
    if (!bShotAnim && Shielding)
        SetAnimAction('HoldShield');
}

simulated function PlayFlying( bool bIsMoving )
{
    PlayInAir();
}
simulated function PlayWaiting()
{
    local float decision;
    local name AnimSequence;

    if( Shielding )
        return;

    decision = FRand();
    AnimSequence = GetAnimSequence();
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
    if( Shielding )
        return;
    LoopAnim('Walk', 0.88,0.2);
}
simulated function PlayRunning( byte MovementDir )
{
    if( Shielding )
        return;
    if( MovementDir==0 || MovementDir==1 )
        LoopAnim('Jog',-1.0/GroundSpeed,0.1, 0.5);
    else if( MovementDir==2 )
        LoopAnim('StrafeLeft',-2.5/GroundSpeed,0.1, 1.0);
    else LoopAnim('StrafeRight',-2.5/GroundSpeed,0.1, 1.0);
}
simulated function PlayInAir()
{
    if( Shielding )
        return;
    PlayAnim('Jump2',0.4,0.2);
}
simulated function PlayLandingAnimation(float ImpactVel)
{
    if( Shielding )
        return;
    if( impactVel > 1.7 * JumpZ )
        TweenAnim('Landed',0.1);
    else TweenAnim('Land', 0.1);
}
simulated function PlaySwimming()
{
    if( Shielding )
        return;
    PlayAnim('Swim',0.4,0.2);
}

defaultproperties
{
     TauntAnimNames(14)="Shield Test"
     TauntAnimNames(15)="Pick Up"
     TauntAnims(14)="ShldTest"
     TauntAnims(15)="Pickup"
     bUseFireTime=True
     bUseShield=True
     ProjectileClass=Class'SkaarjPack.SkaarjProjectile'
     smpRefireRate=0.400000
     Health=200
     MovementAnims(0)="Jog"
     MovementAnims(1)="StrafeRight"
     MovementAnims(2)="StrafeRight"
     MovementAnims(3)="StrafeLeft"
     TurnLeftAnim="Breath"
     TurnRightAnim="Breath"
     WalkAnims(0)="Walk"
     WalkAnims(1)="Walk"
     WalkAnims(2)="Walk"
     WalkAnims(3)="Walk"
     DodgeAnims(0)="Lunge"
     DodgeAnims(1)="Jump"
     DodgeAnims(2)="RightDodge"
     DodgeAnims(3)="LeftDodge"
     Mesh=VertMesh'satoreMonsterPackMeshes.sktrooper'
     Skins(0)=Texture'satoreMonsterPackTexture.Skins.sktrooper1'
     Skins(1)=FinalBlend'XEffectMat.Shield.BlueShell'
     CollisionHeight=42.000000
}
