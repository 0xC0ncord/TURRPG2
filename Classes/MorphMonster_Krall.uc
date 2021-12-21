//=============================================================================
// MorphMonster_Krall.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Krall extends MorphMonster;

var bool bAttackSuccess;
var bool bLegless;
var bool bSuperAggressive;
var name MeleeAttack[5];

replication
{
    unreliable if(Role==ROLE_Authority)
        bLegless;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    bSuperAggressive = (FRand() < 0.5);
}

function RangedAttack(Actor A)
{
    if (bShotAnim)
        return;

    if (bLegless)
        SetAnimAction('Shoot3');
    else if(Physics == PHYS_Swimming)
        SetAnimAction('SwimFire');
    else if(A != None && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
    {
        PlaySound(sound'strike1k', SLOT_Talk);
        SetAnimAction(MeleeAttack[Rand(5)]);
    }
    else
    {
        if(bSuperAggressive && !Controller.bPreparingMove && Controller.InLatentExecution(Controller.LATENT_MOVETOWARD))
            return;
        if(Controller.InLatentExecution(501)) // LATENT_MOVETO
            return;
        SetAnimAction('Shoot1');
    }
    Controller.bPreparingMove = true;
    Acceleration = vect(0, 0, 0);
    bShotAnim = true;
}

function StrikeDamageTarget()
{
    if(MeleeDamageTarget(20, 21000 * Normal(Controller.Target.Location - Location)))
        PlaySound(sound'hit2k', SLOT_Interact);
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.9 * X - 0.5 * Y;
}

function SpawnShot()
{
    FireProjectile();
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local rotator r;

    if (bLegless)
        return;

    if((Health > 30) || (Damage < 20) || (HitLocation.Z > Location.Z))
    {
        Super.PlayTakeHit(HitLocation, Damage, DamageType);
        return;
    }
    r = rotator(Location - HitLocation);
    CreateGib('lthigh',DamageType,r);
    CreateGib('rthigh',DamageType,r);

    bWaitForAnim = false;
    SetAnimAction('LegLoss');
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    Super.PlayDying(DamageType,HitLoc);

    if(bLegless)
        PlayAnim('LeglessDeath', 0.05);
}

simulated event SetAnimAction(name NewAction)
{
    if(NewAction == 'LegLoss')
    {
        bWaitForAnim = false;
        GroundSpeed = 100;
        bCanStrafe = false;
        bMeleeFighter = true;
        bLegless = true;
        SetCollisionSize(CollisionRadius, 16);
        PrePivot = vect(0, 0, 1) * (Default.CollisionHeight - 16);

        MovementAnims[0] = 'Drag';
        SwimAnims[0] = 'Drag';
        CrouchAnims[0] = 'Drag';
        WalkAnims[0] = 'Drag';
        AirAnims[0] = 'Drag';
        TakeOffAnims[0] = 'Drag';
        LandAnims[0] = 'Drag';
        DodgeAnims[0] = 'Drag';
        MovementAnims[1] = 'Drag';
        SwimAnims[1] = 'Drag';
        CrouchAnims[1] = 'Drag';
        WalkAnims[1] = 'Drag';
        AirAnims[1] = 'Drag';
        TakeOffAnims[1] = 'Drag';
        LandAnims[1] = 'Drag';
        DodgeAnims[1] = 'Drag';
        MovementAnims[2] = 'Drag';
        SwimAnims[2] = 'Drag';
        CrouchAnims[2] = 'Drag';
        WalkAnims[2] = 'Drag';
        AirAnims[2] = 'Drag';
        TakeOffAnims[2] = 'Drag';
        LandAnims[2] = 'Drag';
        DodgeAnims[2] = 'Drag';

        IdleWeaponAnim = 'Drag';
        IdleHeavyAnim = 'Drag';
        IdleRifleAnim = 'Drag';
        IdleRestAnim = 'Drag';
        IdleCrouchAnim = 'Drag';
        IdleSwimAnim = 'Drag';
        AirStillAnim = 'Drag';
        TakeoffStillAnim = 'Drag';
        TurnRightAnim = 'Drag';
        TurnLeftAnim = 'Drag';
        CrouchTurnRightAnim = 'Drag';
        CrouchTurnLeftAnim = 'Drag';
    }
    Super.SetAnimAction(NewAction);
}

function PlayVictory()
{
    if(bLegless)
        return;
    Controller.bPreparingMove = true;
    Acceleration = vect(0, 0, 0);
    bShotAnim = true;
    PlaySound(sound'staflp4k', SLOT_Interact);
    SetAnimAction('Twirl');
}

function ThrowDamageTarget()
{
    bAttackSuccess = MeleeDamageTarget(30, vect(0, 0, 0));
    if(bAttackSuccess)
        PlaySound(sound'hit2k', SLOT_Interact);
}

function ThrowTarget()
{
    if(bAttackSuccess && (VSize(Controller.Target.Location - Location) < CollisionRadius + Controller.Target.CollisionRadius + 1.5 * MeleeRange))
    {
        PlaySound(sound'hit2k', SLOT_Interact);
        if(Pawn(Controller.Target) != None)
        {
            Pawn(Controller.Target).AddVelocity(
                (50000.0 * (Normal(Controller.Target.Location - Location) + vect(0, 0, 1))) / Controller.Target.Mass);
        }
    }
}

simulated function PlayFlying(bool bIsMoving)
{
    PlayInAir();
}

simulated function PlayWaiting()
{
    local float decision;
    local name AnimSequence;

    AnimSequence = GetCurrentAnim();

    decision = FRand();
    if(AnimSequence == 'Idle_Rest')
    {
        if(decision < 0.2)
            LoopAnim('look');
        else
            LoopAnim('Idle_Rest',, 0.4);
    }
    else if(decision < 0.1)
        LoopAnim('look',, 0.1);
    else
        LoopAnim('Idle_Rest',, 0.1);
}

simulated function PlayWalking()
{
    if(bLegless)
        LoopAnim('Drag',, 0.1);
    else
        LoopAnim('WalkF', 0.88, 0.1);
}

simulated function PlayRunning(byte MovementDir)
{
    if(bLegless)
        LoopAnim('Drag',, 0.1);
    else
        LoopAnim('RunF', -1.0 / GroundSpeed, 0.1, 0.4);
}

simulated function PlayInAir()
{
    if(bLegless)
        TweenAnim('Drag', 0.3);
    else
        TweenAnim('Jump', 0.2);
}

simulated function PlayLandingAnimation(float ImpactVel)
{
    if(bLegless)
        TweenAnim('Drag', 0.3);
    else
        TweenAnim('Land', 0.1);
}

simulated function PlaySwimming()
{
    LoopAnim('WalkF', 0.6, 0.1);
}

function PlayTaunt()
{
    if(CurTauntAnim == '')
        return;

    Controller.bPreparingMove = true;
    Acceleration = vect(0, 0, 0);
    bShotAnim = true;
    SetAnimAction(CurTauntAnim);
    if(CurTauntSound != None)
    {
        if(CurTauntAnim == 'Laugh')
            PlaySound(CurTauntSound, SLOT_Talk, 1.0,,, (FRand() * 0.2 + 1.5));
        else
            PlaySound(CurTauntSound, SLOT_Talk, 1.0);
    }

    CurTauntAnim='';
    CurTauntSound=None;
}

defaultproperties
{
    TauntAnimNames(1)="Look"
    TauntAnimNames(2)="Sit"
    TauntAnimNames(3)="Grasp"
    TauntAnimNames(4)="Head Rub"
    TauntAnimNames(5)="Laugh"
    TauntAnimNames(6)="Roll Dice"
    TauntAnims(1)="look"
    TauntAnims(2)="Breath2"
    TauntAnims(3)="Grasp"
    TauntAnims(4)="HeadRub"
    TauntAnims(5)="Laugh"
    TauntAnims(6)="Toss"
    TauntSounds(5)=Sound'SkaarjPack_rc.laugh1WL'
    FireAnims(0)="Shoot3"
    FireAnims(1)="SwimFire"
    FireAnims(2)="Shoot1"
    FireAnims(3)="Strike1"
    FireAnims(4)="Strike2"
    FireAnims(5)="Strike3"
    FireAnims(6)="Throw"
    MeleeAttack(0)="Strike1"
    MeleeAttack(1)="Strike2"
    MeleeAttack(2)="Strike3"
    MeleeAttack(3)="Throw"
    MeleeAttack(4)="Throw"
    HitSound(0)=Sound'SkaarjPack_rc.Krall.injur1k'
    HitSound(1)=Sound'SkaarjPack_rc.Krall.injur2k'
    HitSound(2)=Sound'SkaarjPack_rc.Krall.injur1k'
    HitSound(3)=Sound'SkaarjPack_rc.Krall.injur2k'
    DeathSound(0)=Sound'SkaarjPack_rc.Krall.death1k'
    DeathSound(1)=Sound'SkaarjPack_rc.Krall.death2k'
    DeathSound(2)=Sound'SkaarjPack_rc.Krall.death1k'
    DeathSound(3)=Sound'SkaarjPack_rc.Krall.death2k'
    ChallengeSound(0)=Sound'SkaarjPack_rc.Krall.chlng1k'
    ChallengeSound(1)=Sound'SkaarjPack_rc.Krall.chlng2k'
    ChallengeSound(2)=Sound'SkaarjPack_rc.Krall.chlng1k'
    ChallengeSound(3)=Sound'SkaarjPack_rc.Krall.chlng2k'
    FireSound=SoundGroup'WeaponSounds.ShockRifle.ShockRifleAltFire'
    AmmunitionClass=Class'SkaarjPack.KrallAmmo'
    ScoringValue=2
    bCanStrafe=False
    JumpZ=550.000000
    MovementAnims(1)="RunF"
    MovementAnims(2)="RunF"
    MovementAnims(3)="RunF"
    SwimAnims(0)="Swim"
    SwimAnims(1)="Swim"
    SwimAnims(2)="Swim"
    SwimAnims(3)="Swim"
    WalkAnims(1)="WalkF"
    WalkAnims(2)="WalkF"
    WalkAnims(3)="WalkF"
    IdleSwimAnim="Swim"
    Mesh=VertMesh'SkaarjPack_rc.KrallM'
    Skins(0)=FinalBlend'SkaarjPackSkins.Skins.jkrall'
    Skins(1)=FinalBlend'SkaarjPackSkins.Skins.jkrall'
}
