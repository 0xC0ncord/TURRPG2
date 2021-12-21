//=============================================================================
// MorphMonster.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster extends Monster;

//server
var bool bClientIsFiring;
var byte bFire;
var byte bAltFire;
var float LastDodgingTime,bIgnoreFlyTime,LastTauntTime;
var eDoubleClickDir TriedDodgeM;
var byte DummyRepByte;
struct ActionAnimRepType
{
    var name AnimNamez;
    var byte UpdCounterz;
};
var ActionAnimRepType AnimActionRep;
var bool bInWater;

//client
var bool bClientSideFiring;
var bool bWasFire,bWasAltFire;

//both
var RPGPlayerReplicationInfo RPRI;
var float LastAnimEndTimer;
var name LastUsedAnim;
var bool bDoingAnimAction;
var byte MovementAnimNumber;

//victory anim usually is "Victory" but this anim never actually exists, its handled by FindValidTaunt
var bool bPlayingVictory;
var bool bTauntNext;
var bool bPlayingTaunt;
var name CurTauntAnim;
var sound CurTauntSound;

//properties
var bool bCheckMovingDir;
var bool bUseFireTime;
var float NextFireTime;
var float FireAnimSpeed;
var name FireAnims[16];
var float VampMultiplier;
var array<Sound> TauntSounds; //to combine with taunt anim, if there is a sound for it

//internal
var bool bAllowNetNotify;

replication
{
    // Variables the server should send to the client.
    reliable if( bNetDirty && (Role==ROLE_Authority) && !bReplicateAnimations && !bNetOwner )
        AnimActionRep,DummyRepByte,bInWater,FireAnimSpeed;
    reliable if( Role<ROLE_Authority )
        PlayerFired,ServerStopFiring,ServerDoTaunt;
    reliable if( Role==ROLE_Authority )
        ClientSetAnim,ClientSetFireAnimSpeed;
}

simulated function ClientSetFireAnimSpeed(float NewFireAnimSpeed)
{
    FireAnimSpeed=NewFireAnimSpeed;
}

function ProcessAttack(byte Mode)
{
    if(Mode==0)
        RangedAttack(Controller.Target);
}

function PreBeginPlay()
{
    Super.PreBeginPlay();
    bInWater = (PhysicsVolume!=None && PhysicsVolume.bWaterVolume);
}

simulated function PostNetBeginPlay()
{
    AnimActionRep.UpdCounterz = 0;
    Super.PostNetBeginPlay();
    bAllowNetNotify = True;

    RPRI=class'RPGPlayerReplicationInfo'.static.GetFor(Controller);
}

function bool SameSpeciesAs(Pawn P)
{
    return ( MorphMonster(P)!=None );
}

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow);
simulated function vector CalcDrawOffset(inventory Inv)
{
    if(Weapon(Inv)!=None)
        return vector(Rotation)*-1000;
    return Super.CalcDrawOffset(Inv);
}

simulated function Tick(float DeltaTime)
{
    local byte i;
    local bool bFound;

    if(bShotAnim)
    {
        for(i=0; i<16; i++)
        {
            if(string(GetCurrentAnim())~=string(FireAnims[i]))
            {
                bFound=True;
                break;
            }
            else if(GetCurrentAnim()=='')
                break;
        }
        if(!bFound)
            bShotAnim=false; //sometimes bShotAnim gets locked at true if we're firing when we really aren't doing anything which doesn't set off the action
    }

    if(bVictoryNext && Physics!=PHYS_Falling)
    {
        bVictoryNext = False;
        bPlayingVictory=True;
        PlayVictory();
        return;
    }
    else if(bTauntNext && Physics!=PHYS_Falling)
    {
        bTauntNext = False;
        bPlayingTaunt = True;
        PlayTaunt();
        return;
    }

    if( bClientSideFiring ) //client
    {
        if(PlayerController(Controller) != None)
        {
            if(PlayerController(Controller).bFire == 0 && PlayerController(Controller).bAltFire == 0)
            {
                bClientSideFiring = False;
                ServerStopFiring(3);
                bWasFire = false;
                bWasAltFire = false;
            }
            else if(bWasFire && PlayerController(Controller).bFire == 0)
            {
                ServerStopFiring(1);
                bWasFire = false;
            }
            else if(bWasAltFire && PlayerController(Controller).bAltFire == 0)
            {
                ServerStopFiring(2);
                bWasAltFire = false;
            }
        }
        else if(Controller == None)
        {
            bClientSideFiring = false;
            bWasFire = false;
            bWasAltFire = false;
        }
    }
    else if(bClientIsFiring) //server
    {
        if(bUseFireTime && NextFireTime <= Level.TimeSeconds)
        {
            if(bFire == 1)
                PlayerFired(0); // Keep firing as long as client is pressing it.
            if(bAltFire == 1)
                PlayerFired(1); // Keep firing as long as client is pressing it.
        }
    }
    if( (Level.NetMode!=NM_DedicatedServer) && !bPhysicsAnimUpdate && !bDoingAnimAction && Health>0 )
        UpdateMovementAnim();
    if( bPhysicsAnimUpdate && PlayerController(Controller)!=None )
        LastRenderTime = Level.TimeSeconds; // Fake, to update animations all the time

    if(bPlayingVictory || bPlayingTaunt)
        Acceleration=vect(0,0,0);

    if(Weapon!=None && Weapon.ThirdPersonActor!=None && Weapon.ThirdPersonActor.DrawType!=DT_None)
        Weapon.ThirdPersonActor.SetDrawType(DT_None);

    Super.Tick(DeltaTime);
}

function ServerStopFiring(byte Mode)
{
    if(Mode==3)
    {
        bClientIsFiring = False;
        bFire=0;
        bAltFire=0;
    }
    if(Mode==1)
    {
        bFire=0;
    }
    if(Mode==2)
    {
        bAltFire=0;
    }
}

simulated function Fire( optional float F )
{
    if(PlayerController(Controller)==None)
        return;
    bClientSideFiring = True; // Client side.

    if(!bWasAltFire)
    {
        bWasFire=True;
        PlayerFired(0);
    }
    else
    {
        PlayerFired(2);
    }
}
simulated function AltFire( optional float F )
{
    if(PlayerController(Controller)==None)
        return;
    bClientSideFiring = True; // Client side.
    bWasAltFire=True;
    PlayerFired(1);
}

function PlayerFired(byte Mode)
{
    local Actor A;

    if(Mode==0)
        bFire=1;
    if(Mode==1)
        bAltFire=1;

    bClientIsFiring = True; // Serverside.

    if( Controller==None || bShotAnim ) Return;
    A = class'Util'.static.GetClosestPawn(Controller);
    if( A!=None )
    {
        Controller.Target = A;
        Controller.Enemy = Pawn(A);
    }
    ProcessAttack(Mode);
}

function bool DoJump( bool bUpdating )
{
    if( Physics==PHYS_Flying )
        Return True;
    if( bCanFly && PlayerController(Controller)!=None && Physics!=PHYS_Flying )
    {
        if( (bIgnoreFlyTime-Level.TimeSeconds)>0 )
            Return True;
        Controller.GoToState('PlayerFlying');
        SetPhysics(PHYS_Flying);
        Velocity.Z+=30;
        Return True;
    }
    else if ( bCanJump && Super.DoJump(bUpdating) )
    {
        if ( !bUpdating )
            PlayOwnedSound(ChallengeSound[Rand(4)], SLOT_Pain, GruntVolume,,80);
        return true;
    }
    Return False;
}
simulated event Landed(vector HitNormal)
{
    if( Level.NetMode!=NM_Client )
    {
        TakeFallingDamage();
        if ( (Velocity.Z < -200) && (PlayerController(Controller) != None) )
        {
            bJustLanded = PlayerController(Controller).bLandingShake;
            OldZ = Location.Z;
        }
    }
//  if ( !bPhysicsAnimUpdate && !bDoingAnimAction )
    if ( !bDoingAnimAction )
        PlayLandingAnimation(Velocity.Z);
    ImpactVelocity = vect(0,0,0);
    LastHitBy = None;
}
function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
    local float VelocityZ;
    local name Anim;

    if( LastDodgingTime>Level.TimeSeconds || !bCanDodge )
        Return False;
    if( bShotAnim )
    {
        TriedDodgeM = DoubleClickMove;
        Return False;
    }
    if ( Physics == PHYS_Falling )
    {
        if (DoubleClickMove == DCLICK_Forward)
            Anim = WallDodgeAnims[0];
        else if (DoubleClickMove == DCLICK_Back)
            Anim = WallDodgeAnims[1];
        else if (DoubleClickMove == DCLICK_Left)
            Anim = WallDodgeAnims[2];
        else if (DoubleClickMove == DCLICK_Right)
            Anim = WallDodgeAnims[3];

        SetAnimAction(Anim);

        TakeFallingDamage();
        if (Velocity.Z < -DodgeSpeedZ*0.5)
            Velocity.Z += DodgeSpeedZ*0.5;
    }
    else if( !bPhysicsAnimUpdate )
    {
        if (DoubleClickMove == DCLICK_Forward)
            Anim = DodgeAnims[0];
        else if (DoubleClickMove == DCLICK_Back)
            Anim = DodgeAnims[1];
        else if (DoubleClickMove == DCLICK_Left)
            Anim = DodgeAnims[2];
        else if (DoubleClickMove == DCLICK_Right)
            Anim = DodgeAnims[3];
        SetAnimAction(Anim);
    }

    VelocityZ = Velocity.Z;
    Velocity = DodgeSpeedFactor*GroundSpeed*Dir + (Velocity Dot Cross)*Cross;

    if ( !bCanDodgeDoubleJump )
        MultiJumpRemaining = 0;
    if ( bCanBoostDodge || (Velocity.Z < -100) )
        Velocity.Z = VelocityZ + DodgeSpeedZ;
    else
        Velocity.Z = DodgeSpeedZ;

    bShotAnim = IsAnimating();
    CurrentDir = DoubleClickMove;
    SetPhysics(PHYS_Falling);
    PlayOwnedSound(ChallengeSound[Rand(4)], SLOT_Pain, GruntVolume,,80);
    LastDodgingTime = Level.TimeSeconds+1;
    return true;
}
function PlayWeaponSwitch(Weapon NewWeapon);
simulated event SetAnimAction(name NewAction)
{
    if( NewAction=='' ) Return;
    bPhysicsAnimUpdate = False; // Temporarly
    bDoingAnimAction = True;
    if( Level.NetMode!=NM_Client )
    {
        AnimActionRep.AnimNamez = NewAction;
        AnimActionRep.UpdCounterz++;
        if( AnimActionRep.UpdCounterz>250 )
            AnimActionRep.UpdCounterz = 1;
        DummyRepByte = AnimActionRep.UpdCounterz;
        ClientSetAnim(NewAction);
    }
    DoPlayAnimAction(NewAction);
}
simulated function DoPlayAnimAction( name AnimN )
{
    local bool bFireAnim;
    local byte i;

    if( HasAnim(AnimN) )
    {
        for(i=0; i<16; i++)
        {
            if(string(AnimN)~=string(FireAnims[i]))
            {
                bFireAnim=True;
                break;
            }
        }
        if(bFireAnim)
            PlayAnim(AnimN,FireAnimSpeed,0.1);
        else
            PlayAnim(AnimN,,0.1);
    }
}
simulated function ClientSetAnim( name AnimName )
{
    if( Level.NetMode==NM_Client )
        SetAnimAction(AnimName);
}
simulated function name GetCurrentAnim()
{
    local name Anim;
    local float frame,rate;

    GetAnimParams(0, Anim,frame,rate);
    Return Anim;
}
simulated function AnimEnd( int Channel )
{
    if( LastAnimEndTimer==Level.TimeSeconds )
        Return;
    LastAnimEndTimer = Level.TimeSeconds;
    bShotAnim = false;
    bDoingAnimAction = False;
    bPlayingVictory = False;
    bPlayingTaunt = False;
    if( Controller!=None )
        Controller.bPreparingMove = False;
    if( TriedDodgeM!=DCLICK_None )
    {
        if( Dodge(TriedDodgeM) )
            TriedDodgeM = DCLICK_None;
        if( bDoingAnimAction )
            Return;
    }
    else if( Level.NetMode!=NM_Client && bClientIsFiring )
    {
        if( PlayerController(Controller)==None )
            bClientIsFiring = False; // no longer being controlled.
        else
        {
            if(bFire==1)
                PlayerFired(0); // Keep firing as long as client is pressing it.
            if(bAltFire==1)
                PlayerFired(1); // Keep firing as long as client is pressing it.
            if( bDoingAnimAction )
                Return;
        }
    }
    else if( bVictoryNext && Physics!=PHYS_Falling )
    {
        bVictoryNext = False;
        bPlayingVictory=True;
        PlayVictory();
        if( bDoingAnimAction )
            Return;
    }
    else if(bTauntNext && Physics!=PHYS_Falling)
    {
        bTauntNext=False;
        bPlayingTaunt=True;
        PlayTaunt();
        if(bDoingAnimAction)
            return;
    }
    bPhysicsAnimUpdate = Default.bPhysicsAnimUpdate;
    MovementAnimNumber = 0;
    if( Level.NetMode!=NM_DedicatedServer && !bPhysicsAnimUpdate && Health>0 )
        UpdateMovementAnim();
    Super.AnimEnd(Channel);
    if( Controller!=None )
        Controller.AnimEnd(Channel);
}
simulated function UpdateMovementAnim()
{
    local vector RealVelo;
    local byte MoveDir;
    local bool bMoving;

    bShotAnim = false; // This SHOULDNT be True at this point.
    if( (PhysicsVolume!=None && PhysicsVolume.bWaterVolume) || Physics==PHYS_Swimming || bInWater )
    {
        if( MovementAnimNumber!=4 )
        {
            MovementAnimNumber = 4;
            PlaySwimming();
        }
    }
    else if( Physics==PHYS_Falling )
    {
        if( MovementAnimNumber!=3 )
        {
            MovementAnimNumber = 3;
            PlayInAir();
        }
    }
    else
    {
        RealVelo = Velocity;
        if( Base!=None && Base.Physics!=PHYS_None )
            RealVelo-=Base.Velocity;
        bMoving = (VSize(RealVelo)>20);
        if( Physics==PHYS_Flying )
        {
            if( MovementAnimNumber!=2 )
            {
                MovementAnimNumber = 2;
                PlayFlying(bMoving);
            }
        }
        else if( bMoving && bIsWalking )
        {
            if( MovementAnimNumber!=1 )
            {
                MovementAnimNumber = 1;
                PlayWalking();
            }
        }
        else if( bMoving )
        {
            MoveDir = GetMoveDir(RealVelo)+6;
            if( MovementAnimNumber!=MoveDir )
            {
                MovementAnimNumber = MoveDir;
                PlayRunning(MoveDir-6);
            }
        }
        else if( MovementAnimNumber!=5 )
        {
            MovementAnimNumber = 5;
            PlayWaiting();
        }
    }
}
// 0 - Forward
// 1 - Backward
// 2 - Strafe Left
// 3 - Strafe Right
simulated function byte GetMoveDir( vector MoveVelo )
{
    local vector lookDir, moveDir, Y;
    local rotator Ro;
    local float strafeMag;

    if(!bCheckMovingDir)
        Return 0;
    moveDir = MoveVelo;
    moveDir.Z = 0;
    moveDir = Normal(moveDir);
    Ro = Rotation;
    Ro.Pitch = 0;
    Ro.Roll = 0;
    lookDir = vector(Ro);
    strafeMag = lookDir dot moveDir;
    if (strafeMag > 0.8)
        Return 0;
    else if (strafeMag < -0.8)
        Return 1;
    Y = (lookDir Cross vect(0,0,1));
    if( (Y Dot moveDir)>0 )
        Return 3;
    else Return 2;
}
simulated function PostNetReceive()
{
    if( Level.NetMode!=NM_Client )
        Return;
    if( bAllowNetNotify )
    {
        if( AnimActionRep.UpdCounterz>0 )
        {
            AnimActionRep.UpdCounterz = 0;
            SetAnimAction(AnimActionRep.AnimNamez);
        }
    }
}
event PhysicsVolumeChange( PhysicsVolume NewVolume )
{
    if( Level.NetMode!=NM_Client )
        bInWater = NewVolume.bWaterVolume;
    Super.PhysicsVolumeChange(NewVolume);
}
simulated function bool FindValidTaunt( out name Sequence )
{
    bIgnoreFlyTime = Level.TimeSeconds+1;
    if( Level.NetMode==NM_Client )
    {
        ServerDoTaunt(Sequence);
        Return false;
    }
    if( PlayerController(Controller)!=None && Physics==PHYS_Flying )
    {
        Controller.GoToState('PlayerWalking');
        SetPhysics(PHYS_Falling);
        Return false;
    }
    else if( (LastTauntTime-Level.TimeSeconds)<0 )
    {
        LastTauntTime = Level.TimeSeconds+3;
        if(Sequence=='Victory')
            PlayVictoryAnimation();
        else
            PlayTauntAnimation(Sequence);
        Return False;
    }
    else Return False;
}
function PlayTauntAnimation(name TauntName)
{
    local int i;

    CurTauntAnim=TauntName;
    for(i=0; i<TauntAnims.Length; i++)
        if(string(TauntAnims[i])~=string(TauntName))
            break;
    if(i<TauntSounds.Length && TauntSounds[i]!=None)
        CurTauntSound=TauntSounds[i];
    bTauntNext=True;
}
function PlayTaunt()
{
    if(CurTauntAnim=='')
        return;
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    SetAnimAction(CurTauntAnim);
    if(CurTauntSound!=None)
        PlaySound(CurTauntSound,SLOT_Talk,1.0);

    CurTauntAnim='';
    CurTauntSound=None;
}
function ServerDoTaunt(name Sequence)
{
    FindValidTaunt(Sequence);
}
simulated function PlayFlying( bool bIsMoving )
{
    PlayInAir();
}
simulated function PlayWaiting();
simulated function PlayRunning( byte MovementDir );
simulated function PlayWalking();
simulated function PlayInAir();
simulated function PlaySwimming();

function PlayMoverHitSound()
{
    PlaySound(HitSound[Rand(4)], SLOT_Interact);
}

defaultproperties
{
     VampMultiplier=1.000000
     bCanJump=True
     bCanPickupInventory=True
     FireAnimSpeed=1.000000
     bPhysicsAnimUpdate=False
     TauntAnims(0)="Victory"
     TauntAnimNames(0)="Victory"
     bNoRepMesh=True
}
