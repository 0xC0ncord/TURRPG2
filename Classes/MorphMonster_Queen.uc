//=============================================================================
// MorphMonster_Queen.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Queen extends MorphMonster_SMPMonster;

var() name ScreamEvent;

var ColorModifier QueenFadeOutSkin;

var vector TelepDest;
var byte row;
var SMPQueenShield Shield;

var bool    bJustScreamed;
var() int ClawDamage,
    StabDamage;

var     byte AChannel;

var() sound Acquire,Fear,Roam,footstepSound,ScreamSound,
                            stab,shoot,claw,Threaten;

var float LastTelepoTime;

var bool bTeleporting;

var Pawn TeleportTarget;
var float NextTeleportTime;

var int NumChildren;
var config int MaxChildren;
var config float ChildSpawnPerSecChance;
var config float TeleportCooldown;
var config bool bCanSpawnChildren;

replication
{
    reliable if(Role==ROLE_Authority)
         bTeleporting;
    reliable if(Role==ROLE_Authority)
        ClientTeleported,ClientInitializeIcon;
}

function PlayVictory()
{
    if(Controller!=none)
    {
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        PlaySound(Threaten,SLOT_Interact);
        SetAnimAction('ThreeHit');
    }
}

function RangedAttack(Actor A)
{
    local float decision;

    if ( bShotAnim )
        return;
    decision = FRand();
    if ( A!=None && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        if (decision < 0.4)
        {
            PlaySound(Stab, SLOT_Interact);
            SetAnimAction('Stab');
        }
        else if (decision < 0.7)
        {
            PlaySound(Claw, SLOT_Interact);
            SetAnimAction('Claw');
        }
        else
        {
            PlaySound(Claw, SLOT_Interact);
            SetAnimAction('Gouge');
        }
    }
    else if((decision < 0.8 && Shield != None ) || decision < 0.4)
    {
        if ( Shield != None )
            Shield.Destroy();
        row = 0;
        bJustScreamed = false;
        SetAnimAction('Shoot1');
        PlaySound(Shoot, SLOT_Interact);
    }
    else
    {
        if ( Shield != None )
            Shield.Destroy();
        row = 0;
        bJustScreamed = false;
        SetAnimAction('Shoot1');
        PlaySound(Shoot, SLOT_Interact);
    }
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
}

simulated function Tick(float DeltaTime)
{
    if(bTeleporting)
    {
        AChannel-=300 *DeltaTime;
    }
    else
        AChannel=255;
    QueenFadeOutSkin.Color.A=AChannel;

    if(Shield!=none)
    {
        Shield.SetDrawScale(Shield.default.DrawScale*DrawScale);
        Shield.AimedOffset.X=CollisionRadius;
        Shield.AimedOffset.Y=CollisionRadius;
        Shield.SetCollisionSize(CollisionRadius*1.2,CollisionHeight*1.2);
    }

    Super.Tick(DeltaTime);
}

function ChooseDestination()
{
    local NavigationPoint N;
    local vector ViewPoint, Best;
    local float rating, newrating;
    local Actor jActor;
    local Pawn P;
    Best = Location;
    TelepDest = Location;
    rating = 0;

    if(TeleportTarget==none)
        return;
    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        newrating = 0;

        ViewPoint = N.Location +vect(0,0,1)*CollisionHeight*0.5f;
        if (FastTrace( TeleportTarget.Location,ViewPoint))
            newrating += 20000;
        newrating -= VSize(N.Location - TeleportTarget.Location) + 1000 * FRand();
        foreach N.VisibleCollidingActors(class'Actor',jActor,CollisionRadius,ViewPoint)
            newrating -= 30000;
        foreach N.VisibleCollidingActors(class'Pawn',P,CollisionRadius,ViewPoint)
            if(P.Controller!=None && Controller.SameTeamAs(P.Controller) || !MayTelefrag(P))
                newrating -= 75000;
        if ( newrating > rating )
        {
            rating = newrating;
            Best = N.Location;
        }
    }
    TelepDest = Best;
    TeleportTarget = None;
}

function Teleport()
{
    local rotator EnemyRot;
    local Controller C;
    local bool bFailed;

    if ( Role == ROLE_Authority )
        ChooseDestination();

    if(TelepDest!=vect(0,0,0))
        for(C=Level.ControllerList; C!=None; C=C.NextController)
            if(C.Pawn!=None && C.Pawn!=Self && VSize(C.Pawn.Location-TelepDest)<CollisionRadius+C.Pawn.CollisionRadius && (C.SameTeamAs(Controller) || !MayTelefrag(C.Pawn)))
                return;

    bFailed=!SetLocation(TelepDest+vect(0,0,1)*CollisionHeight*0.5f);
    if(Controller.Enemy!=none && !bFailed)
        EnemyRot = rotator(Controller.Enemy.Location - Location);
    EnemyRot.Pitch = 0;
    ClientTeleported(rotator(Controller.Enemy.Location-(Location+EyePosition())));
    PlaySound(sound'Teleport1', SLOT_Interface);

    if(!bFailed)
    {
        NextTeleportTime=Level.TimeSeconds+TeleportCooldown;
        ClientInitializeIcon();
    }
}

function bool MayTelefrag(Pawn Other)
{
    if(InvasionPro(Level.Game)!=None)
        return InvasionPro(Level.Game).MayBeTeleFragged(Self,Other);
    return true;
}

simulated function ClientTeleported(rotator NewRot)
{
    Controller.SetRotation(NewRot);
    if(Role<Role_Authority)
    {
        NextTeleportTime=30;
        SetTimer(1.0,true);
    }
}

simulated function Timer()
{
    if(Role==Role_Authority)
    {
        if(FRand()<ChildSpawnPerSecChance)
            SpawnChild();
        return;
    }
    NextTeleportTime-=1;
    if(NextTeleportTime<=0)
        SetTimer(0.0,false);
}

function SpawnChild()
{
    local NavigationPoint N;
    local SMPChildPupae P;
    local FriendlyMonsterController_Child C;
    local int i;

    if(!bCanSpawnChildren || numChildren>=MaxChildren)
        return;

    For ( N=Level.NavigationPointList; N!=None && numChildren<MaxChildren; N=N.NextNavigationPoint )
    {
        if(vsize(N.Location-Location)<2000 && FastTrace(N.Location,Location))
        {
            P=spawn(class 'MorphMonster_QueenChildPupae' ,self,,N.Location);
            if(P!=none)
            {
                P.LifeSpan=20+Rand(10);

                if (P.Controller != None)
                    P.Controller.Destroy();
                C = spawn(class'FriendlyMonsterController_Child',,, N.Location);
                C.Possess(P);
                C.SetMaster(Controller);
                C.Parent=Self;

                if (RPRI != None)
                {
                    for(i=0; i<RPRI.Abilities.Length; i++)
                        if(RPRI.Abilities[i].bAllowed)
                            RPRI.Abilities[i].ModifyMonster(P, Self);
                }

                if(P!=None)
                {
                    numChildren++;
                    break;
                }
            }
        }
    }
}

simulated function ClientInitializeIcon()
{
    local StatusIcon_QueenTeleport Status;

    if(Level.NetMode==NM_DedicatedServer)
        return;

    if(RPRI!=None)
    {
        Status=StatusIcon_QueenTeleport(RPRI.GetStatusIcon(class'StatusIcon_QueenTeleport'));
        if(Status==None)
            RPRI.ClientCreateStatusIcon(class'StatusIcon_QueenTeleport');
        else
            Status.Queen=Self;
    }
}

function SpawnShot()
{
    local vector X,Y,Z, projStart;

    if(Controller==none || Role<Role_Authority)
        return;
    GetAxes(Rotation,X,Y,Z);

    if (row == 0)
        MakeNoise(1.0);
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

    projStart = Location + 1 * CollisionRadius * X + ( 0.7 - 0.2 * row) * CollisionHeight * Z + 0.2 * CollisionRadius * Y;
    spawn(MyAmmo.ProjectileClass ,,,projStart,Controller.AdjustAim(SavedFireProperties,projStart,600));

    projStart = Location + 1 * CollisionRadius * X + ( 0.7 - 0.2 * row) * CollisionHeight * Z - 0.2 * CollisionRadius * Y;
    spawn(MyAmmo.ProjectileClass ,,,projStart,Controller.AdjustAim(SavedFireProperties,projStart,600));
    row++;
}

simulated function DoTeleport()
{
    TeleportTarget=Pawn(Controller.Target);
    Controller.Enemy=TeleportTarget;
    if(TeleportTarget==None)
        return;

    SetAnimAction('Meditate');
    GotoState('Teleporting');
    bJustScreamed = false;
}

function ProcessAttack(byte Mode)
{
    if(Mode==0)
        RangedAttack(Controller.Target);
    if(Mode==1)
    {
        if(Shield==None)
        {
            SetAnimAction('Shield');
            Controller.bPreparingMove = true;
            Acceleration = vect(0,0,0);
            bShotAnim = true;
        }
    }
    if(Mode==2)
    {
        if(NextTeleportTime<=Level.TimeSeconds)
            DoTeleport();
    }
}

function ThrowOther(Pawn Other,int Power)
{
    local float dist, shake;
    local vector Momentum;

    if(Other.Controller!=None && Controller!=None && Controller.SameTeamAs(Other.Controller))
        return;

    if ( Other.mass >= Mass )
        return;

    if (xPawn(Other)==none)
    {
        if ( Power<400 || (Other.Physics != PHYS_Walking) )
            return;
        dist = VSize(Location - Other.Location);
        if (dist > Mass)
            return;
    }
    else
    {

        dist = VSize(Location - Other.Location);
        shake = 0.4*FMax(500, Mass - dist);
        shake=FMin(2000,shake);
        if ( dist > Mass )
            return;
        if(Other.Controller!=none)
            Other.Controller.ShakeView( vect(0.0,0.02,0.0)*shake, vect(0,1000,0),0.003*shake, vect(0.02,0.02,0.02)*shake, vect(1000,1000,1000),0.003*shake);

        if ( Other.Physics != PHYS_Walking )
            return;
    }

    Momentum = 100 * Vrand();
    Momentum.Z = FClamp(0,Power,Power - ( 0.4 * dist + Max(10,Other.Mass)*10));
    Other.AddVelocity(Momentum);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    QueenFadeOutSkin= new class'ColorModifier';
    QueenFadeOutSkin.Material=Skins[0];
    Skins[0]=QueenFadeOutSkin;

    if(Role==Role_Authority && bCanSpawnChildren)
        SetTimer(1.0,true);
}

simulated function Destroyed()
{
    local StatusIcon_QueenTeleport Status;

    QueenFadeOutSkin=none;
    if(Shield!=none)
        Shield.Destroy();
    if(RPRI!=None)
    {
        Status=StatusIcon_QueenTeleport(RPRI.GetStatusIcon(class'StatusIcon_QueenTeleport'));
        if(Status!=None)
            Status.Queen=None;
    }
    Super.Destroyed();
}

function SpawnShield()
{
    if(Role<Role_Authority)
        return;

    if(Shield!=none)
        Shield.Destroy();

    Shield = Spawn(class'MorphMonster_QueenShield',,,Location);
    if(Shield!=none)
    {
        Shield.SetDrawScale(Shield.default.DrawScale*DrawScale);
        Shield.AimedOffset.X=CollisionRadius;
        Shield.AimedOffset.Y=CollisionRadius;
        Shield.SetCollisionSize(CollisionRadius*1.2,CollisionHeight*1.2);
    }
}

simulated function FootStep()
{
    PlaySound(FootstepSound, SLOT_Interact, 8);
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
    if(Shield!=none)
        Shield.Destroy();
    GotoState('Dying');

    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetPhysics(PHYS_Falling);

    PlayAnim('OutCold',0.7, 0.1);
}

function Landed(vector HitNormal)
{
    local pawn Thrown;
    if(Velocity.Z<-10)
        foreach CollidingActors( class 'Pawn', Thrown,Mass)
            ThrowOther(Thrown,Mass/12+(-0.5*Velocity.Z));
    super.Landed(HitNormal);
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if(Damage>80)
    {
        PlayDirectionalHit(HitLocation);

    }

    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;
    PlaySound(HitSound[Rand(4)], SLOT_Pain,2*TransientSoundVolume,,400);
}
function PlayDirectionalHit(Vector HitLoc)
{
    TweenAnim('TakeHit', 0.05);
}
function Scream()
{
    local Actor A;
    local int EventNum;

    PlaySound(ScreamSound, SLOT_None, 3 * TransientSoundVolume);
    SetAnimAction('Scream');
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bJustScreamed = true;

    if ( ScreamEvent == '' )
        return;
    ForEach DynamicActors( class 'Actor', A, ScreamEvent )
    {
        A.Trigger(self, Instigator);
        EventNum++;
    }
}

function ClawDamageTarget()
{
    if(Controller==none || Controller.Target==none) return;
    if (MeleeDamageTarget(ClawDamage, (50000.0 * (Normal(Controller.Target.Location - Location)))) )
        PlaySound(Claw, SLOT_Interact);
}

function StabDamageTarget()
{
    local vector X,Y,Z;
    if(Controller==none || Controller.Target==none) return;
    GetAxes(Rotation,X,Y,Z);
    if (MeleeDamageTarget(StabDamage, (15000.0 * ( Y + vect(0,0,1)))) )
        PlaySound(Stab, SLOT_Interact);
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
    local Vector HitDir;
    local Vector FaceDir;
    FaceDir=vector(Rotation);
    HitDir = Normal(Location-HitLocation+ Vect(0,0,8));
    RefNormal=FaceDir;
    if ( FaceDir dot HitDir < -0.26 && Shield!=none) // 68 degree protection arc
    {
        Shield.Flash(Damage);

        return true;
    }
    return false;
}
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                    vector momentum, class<DamageType> damageType)
{
    local vector HitNormal;
    if(CheckReflect(HitLocation,HitNormal,Damage))
        Damage*=0;
    super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

state Teleporting
{
    function Tick(float DeltaTime)
    {
        if(AChannel<20)
        {
            if (ROLE == ROLE_Authority)
                Teleport();
            GotoState('');
        }
        global.Tick(DeltaTime);
    }


    function RangedAttack(Actor A)
    {
        return;
    }
    function BeginState()
    {
        if(Controller.Enemy==none)
        {
            GotoState('');
            return;
        }
        bTeleporting=true;
        Acceleration = Vect(0,0,0);
        bUnlit = true;
        AChannel=255;
        Spawn(class'SMPQueenTeleportEffect',,,Location);
    }

    function EndState()
    {
        bTeleporting=false;
        bUnlit = false;
        AChannel=255;

        LastTelepoTime=Level.TimeSeconds;
    }
}

state Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;
simulated function ProcessHitFX(){}
}

simulated function PlayFlying( bool bIsMoving )
{
    PlayInAir();
}
simulated function PlayWaiting()
{
    LoopAnim('Meditate',,0.1);
}
simulated function PlayWalking()
{
    LoopAnim('Walk', -1.4/GroundSpeed,0.1, 0.4);
}
simulated function PlayRunning( byte MovementDir )
{
    LoopAnim('Run', -1.0/GroundSpeed,0.1, 0.4);
}
simulated function PlayInAir()
{
    LoopAnim('Jump',,0.1);
}
simulated function PlayLandingAnimation(float ImpactVel)
{
    PlayAnim('Land');
}
simulated function PlaySwimming()
{
    PlayWalking();
}

defaultproperties
{
     TauntAnimNames(1)="Scream"
     TauntAnims(1)="Scream"
     TauntSounds(1)=sound'satoreMonsterPackSound.Queen.yell3Q'
     TeleportCooldown=30.000000
     bCanSpawnChildren=True
     MaxChildren=3
     ChildSpawnPerSecChance=0.100000
     FireAnims(0)="Stab"
     FireAnims(1)="Claw"
     FireAnims(2)="Gouge"
     FireAnims(3)="Shoot1"
     FireAnims(4)="Shield"
     ScreamEvent="QScream"
     ClawDamage=70
     StabDamage=90
     AChannel=255
     Acquire=Sound'satoreMonsterPackSound.Queen.yell1Q'
     Fear=Sound'satoreMonsterPackSound.Queen.yell2Q'
     Roam=Sound'satoreMonsterPackSound.Queen.nearby2Q'
     footstepSound=Sound'satoreMonsterPackSound.Titan.step1t'
     ScreamSound=Sound'satoreMonsterPackSound.Queen.yell3Q'
     Stab=Sound'satoreMonsterPackSound.Queen.stab1Q'
     Shoot=Sound'satoreMonsterPackSound.Queen.shoot1Q'
     Claw=Sound'satoreMonsterPackSound.Queen.claw1Q'
     Threaten=Sound'satoreMonsterPackSound.Queen.yell2Q'
     InvalidityMomentumSize=100000.000000
     MonsterName="Queen"
     bNoTeleFrag=True
     bNoCrushVehicle=True
     bBoss=True
     HitSound(0)=Sound'satoreMonsterPackSound.Queen.yell2Q'
     HitSound(1)=Sound'satoreMonsterPackSound.Queen.yell2Q'
     HitSound(2)=Sound'satoreMonsterPackSound.Queen.yell2Q'
     HitSound(3)=Sound'satoreMonsterPackSound.Queen.yell2Q'
     DeathSound(0)=Sound'satoreMonsterPackSound.Queen.outcoldQ'
     DeathSound(1)=Sound'satoreMonsterPackSound.Queen.outcoldQ'
     DeathSound(2)=Sound'satoreMonsterPackSound.Queen.outcoldQ'
     DeathSound(3)=Sound'satoreMonsterPackSound.Queen.outcoldQ'
     AmmunitionClass=Class'satoreMonsterPackv120.SMPQueenAmmo'
     ScoringValue=14
     bCanSwim=False
     MeleeRange=120.000000
     GroundSpeed=600.000000
     AccelRate=1600.000000
     JumpZ=800.000000
     Health=800
     MovementAnims(0)="Run"
     MovementAnims(1)="Run"
     MovementAnims(2)="Run"
     MovementAnims(3)="Run"
     TurnLeftAnim="Walk"
     TurnRightAnim="Walk"
     WalkAnims(0)="Walk"
     WalkAnims(1)="Walk"
     WalkAnims(2)="Walk"
     WalkAnims(3)="Walk"
     IdleWeaponAnim="Meditate"
     IdleRestAnim="Meditate"
     AmbientSound=Sound'satoreMonsterPackSound.Queen.amb1Q'
     Mesh=VertMesh'satoreMonsterPackMeshes.SkQueen'
     Skins(0)=Texture'satoreMonsterPackTexture.Skins.JQueen1'
     Skins(1)=Texture'satoreMonsterPackTexture.Skins.JQueen1'
     TransientSoundVolume=16.000000
     DrawScale=0.500000
     CollisionRadius=45.000000
     CollisionHeight=53.000000
     Mass=500.000000
}
