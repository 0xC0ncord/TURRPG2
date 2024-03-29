//=============================================================================
// FriendlyMonsterController.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Monster that is friendly to a player and follows him/her around
class FriendlyMonsterController extends MonsterController;

var Controller Master;
var RPGPlayerReplicationInfo MasterRPRI;
var int TeamNum;

var float MasterFollowDistance;

var FriendlyPawnReplicationInfo FPRI;

var FX_FriendlyMonster Effect;

var array<NavigationPoint> NavPointList;
var bool bSearching;
var Actor CurrentSearchDestination;
var float SearchingStartTime;
var float MaxSearchingStuckTime;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    FPRI = Spawn(class'FriendlyPawnReplicationInfo');
}

function Possess(Pawn aPawn)
{
    Super(ScriptedController).Possess(aPawn);

    Pawn.MaxFallSpeed = 1.1 * Pawn.default.MaxFallSpeed;
    Pawn.SetMovementPhysics();
    Pawn.bAlwaysRelevant = true; //should stay relevant for global interaction

    if(Pawn.Physics == PHYS_Walking)
        Pawn.SetPhysics(PHYS_Falling);

    FPRI.Pawn = aPawn;

    Enable('NotifyBump');
}

function SetMaster(Controller NewMaster)
{
    Master = NewMaster;
    MasterRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Master);
    FPRI.Master = Master.PlayerReplicationInfo;

    if(Master.PlayerReplicationInfo != None && Master.PlayerReplicationInfo.Team != None)
    {
        TeamNum = Master.PlayerReplicationInfo.Team.TeamIndex;

        PlayerReplicationInfo = Spawn(class'FriendlyPawnPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = Master.PlayerReplicationInfo.PlayerName $ "'s" @ Pawn.GetHumanReadableName();
        PlayerReplicationInfo.Team = Master.PlayerReplicationInfo.Team;

        if(Pawn != None)
        {
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
            Pawn.bNoTeamBeacon = true;
        }
    }
    else
    {
        TeamNum = 255;
    }

    Effect = Pawn.Spawn(class'FX_FriendlyMonster', Pawn);
    Effect.SetBase(Pawn);
    Effect.MasterPRI = Master.PlayerReplicationInfo;
    Effect.Initialize();
}

function Destroyed()
{
    if(PlayerReplicationInfo != None)
        PlayerReplicationInfo.Destroy();
    if(Effect != None)
        Effect.Destroy();
    Super.Destroyed();
}

simulated function int GetTeamNum()
{
    return TeamNum;
}

function bool FindNewEnemy()
{
    local Pawn BestEnemy;
    local float BestDist;
    local Controller C;
    local int Count;

    BestDist = 50000.f;
    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        Count++;
        if(
            C != Master &&
            C != Self &&
            C.Pawn != None &&
            !C.SameTeamAs(Master) &&
            (FriendlyMonsterController(C) == None || FriendlyMonsterController(C).Master != Master) &&
            (CanSee(C.Pawn) || bSearching) &&
            VSize(C.Pawn.Location - Pawn.Location) < BestDist &&
            //!Monster(Pawn).SameSpeciesAs(C.Pawn) - nevermind same species - it's an enemy!
            !C.Pawn.IsA('ParentBlob') &&
            (!C.Pawn.IsA('LenoreBoss') || bool(C.Pawn.GetPropertyText("bIsVulnerableNow"))) &&
            (!C.Pawn.IsA('NaliSage') || bool(C.Pawn.GetPropertyText("bIsAppeared")))
        )
        {
            BestEnemy = C.Pawn;
            BestDist = VSize(C.Pawn.Location - Pawn.Location);
        }
    }

    if(BestEnemy == Enemy)
        return false;

    if(BestEnemy != None)
    {
        ChangeEnemy(BestEnemy, true);
        return true;
    }

    return false;
}

function bool SetEnemy(Pawn NewEnemy, optional bool bThisIsNeverUsed)
{
    local float EnemyDist;

    if(NewEnemy == None || NewEnemy.Health <= 0 || NewEnemy.Controller == None || NewEnemy == Enemy)
        return false;

    if(
        Master != None &&
        (
            (Master.Pawn != None && NewEnemy == Master.Pawn) ||
            (
                FriendlyMonsterController(NewEnemy.Controller) != None &&
                FriendlyMonsterController(NewEnemy.Controller).Master == Master
            )
        )
    )
    {
        return false;
    }

    if(NewEnemy.Controller.SameTeamAs(Master) || (!CanSee(NewEnemy) && !bSearching))
        return false;

    if(Enemy == None)
    {
        ChangeEnemy(NewEnemy, CanSee(NewEnemy));
        return true;
    }

    EnemyDist = VSize(Enemy.Location - Pawn.Location);
    if(EnemyDist < Pawn.MeleeRange)
        return false;

    if(EnemyDist > 1.7 * VSize(NewEnemy.Location - Pawn.Location))
    {
        ChangeEnemy(NewEnemy, CanSee(NewEnemy));
        return true;
    }
    return false;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy)
{
    Super.ChangeEnemy(NewEnemy, bCanSeeNewEnemy);

    CurrentSearchDestination = None;

    //hack for invasion monsters so they'll fight back
    if(
        MonsterController(NewEnemy.Controller) != None &&
        FriendlyMonsterController(NewEnemy.Controller) == None &&
        (NewEnemy.Controller.Enemy == Master.Pawn || FRand() < 0.5)
    )
    {
        MonsterController(NewEnemy.Controller).ChangeEnemy(Pawn, NewEnemy.Controller.CanSee(Pawn));
    }
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
}

event SeePlayer(Pawn SeenPlayer)
{
    if(
        Enemy == None &&
        (ChooseAttackCounter < 2 || ChooseAttackTime != Level.TimeSeconds) &&
        SetEnemy(SeenPlayer)
    )
    {
        WhatToDoNext(3);
    }

    if(Enemy == SeenPlayer)
    {
        VisibleEnemy = Enemy;
        EnemyVisibilityTime = Level.TimeSeconds;
        bEnemyIsVisible = true;
    }
}

event Tick(float dt) {
    Super.Tick(dt);

    if(Pawn == None || Pawn.Controller != Self || Pawn.bPendingDelete) {
        Destroy();
        return;
    }

    //if I don't have a master or he switched teams, I should die
    if(
        Master == None ||
        Master.PlayerReplicationInfo == None ||
        Master.PlayerReplicationInfo.bOnlySpectator ||
        !SameTeamAs(Master)
    )
    {
        Pawn.Suicide();
            return;
    }
    else if(MasterRPRI != None)
    {
        //if my master died, test if I should as well
        if(MasterRPRI.bMonstersDie && (Master.Pawn == None || Master.Pawn.Health <= 0))
        {
            Pawn.Suicide();
            return;
        }
    }

    if(Level.TimeSeconds - SearchingStartTime >= MaxSearchingStuckTime && bSearching)
    {
        CurrentSearchDestination = None;
        SearchAndDestroy();
    }
}

function ExecuteWhatToDoNext()
{
    bHasFired = false;
    GoalString = "WhatToDoNext at "$Level.TimeSeconds;
    if(Pawn == None)
    {
        Warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
        Destroy();
        return;
    }

    if(bPreparingMove && Monster(Pawn).bShotAnim)
    {
        Pawn.Acceleration = vect(0,0,0);
        GotoState('WaitForAnim');
        return;
    }

    if(Pawn.Physics == PHYS_None)
        Pawn.SetMovementPhysics();

    if((Pawn.Physics == PHYS_Falling) && DoWaitForLanding())
        return;

    if(Enemy != None && (Enemy.Health <= 0 || Enemy.Controller == None))
        Enemy = None;

    if(Enemy == None || !EnemyVisible())
    {
        CurrentSearchDestination = None;
        FindNewEnemy();
    }

    if(Enemy != None)
    {
        CurrentSearchDestination = None;
        ChooseAttackMode();
    }
    else if(Master.Pawn != None && !bSearching)
    {
        FollowMaster();
    }
    else
    {
        if(bSearching)
        {
            SearchAndDestroy();
        }
        else
        {
            GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
            WanderOrCamp(true);
        }
    }
}

function FollowMaster()
{
    if(
        VSize(Master.Pawn.Location - Pawn.Location) > MasterFollowDistance ||
        VSize(Master.Pawn.Velocity) > Master.Pawn.WalkingPct * Master.Pawn.GroundSpeed ||
        !LineOfSightTo(Master.Pawn)
    )
    {
        GoalString = "Follow Master "$Master.PlayerReplicationInfo.PlayerName;

        if(FindBestPathToward(Master.Pawn, false, Pawn.bCanPickupInventory))
        {
            GotoState('Roaming');
            return;
        }
    }

    GoalString = "Wander or Camp at "$Level.TimeSeconds;
    WanderOrCamp(true);
    CurrentSearchDestination = None;
}

function SearchAndDestroy()
{
    local NavigationPoint N;

    if(Enemy == None && bSearching)
    {
        GoalString = "Search and destroy";

        if(NavPointList.Length == 0)
            for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
                if(FlyingPathNode(N) != None)
                    NavPointList[NavPointList.Length] = N;

        if(CurrentSearchDestination == None || VSize(Pawn.Location - CurrentSearchDestination.Location) < Pawn.CollisionRadius + 128)
        {
            N = NavPointList[Rand(NavPointList.Length)];
            if(FindBestPathToward(N, false, Pawn.bCanPickupInventory))
            {
                SearchingStartTime = Level.TimeSeconds;
                CurrentSearchDestination = MoveTarget;
                GotoState('Roaming');
                return;
            }
        }
        else
        {
            if(FindBestPathToward(CurrentSearchDestination, false, Pawn.bCanPickupInventory))
            {
                GotoState('Roaming');
                return;
            }
        }
    }

    GoalString = "Wander or Camp at "$Level.TimeSeconds;
    WanderOrCamp(true);
    CurrentSearchDestination = None;
}

function SearchAndDestroyCommand()
{
    bSearching = true;
    SearchAndDestroy();
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
    if(Killer == Self || Killer == Master)
        Celebrate();

    if(KilledPawn == Enemy)
    {
        Enemy = None;
        FindNewEnemy();
    }
}

function bool ShouldCharge(Pawn P)
{
    local vector HitLocation, HitNormal;
    local PhysicsVolume V;

    if(Skill < 5)
        return ActorReachable(Enemy);

    if(P.PhysicsVolume.bPainCausing)
        return false;

    if(P.Physics == PHYS_Walking)
        return ActorReachable(Enemy);

    Trace(HitLocation, HitNormal, P.Location, P.Location - vect(0, 0, 1) * Level.KillZ * 2);
    if(HitLocation != vect(0, 0, 0))
    {
        if(HitLocation.Z <= Level.KillZ)
            return false;

        if(InvasionPro(Level.Game) != None && InvasionPro(Level.Game).CollisionTestActor != None)
        {
            InvasionPro(Level.Game).CollisionTestActor.SetLocation(HitLocation);
            foreach AllActors(class'PhysicsVolume', V)
                if(V != None && v.bPainCausing && V.Encompasses(InvasionPro(Level.Game).CollisionTestActor))
                    return false;
        }
    }
    else
        return false;

    return ActorReachable(Enemy);
}

function Celebrate()
{
    if(
        (Pawn.Physics == PHYS_Flying && Warlord(Pawn) != None)
        || Pawn.Physics == PHYS_Falling
        || Pawn.Physics == PHYS_Swimming
        || Pawn.Physics == PHYS_Spider
        || Pawn.Physics == PHYS_Ladder
        || Pawn.Physics == PHYS_Hovering
    )
        return;

    Super.Celebrate();
}

state RestFormation
{
    function BeginState()
    {
        Enemy = None;
        Pawn.bCanJump = false;
        Pawn.bAvoidLedges = true;
        Pawn.bStopAtLedges = true;
        Pawn.SetWalking(true);
        MinHitWall += 0.15;

        if(Master != None && Master.Pawn != None)
            StartMonitoring(Master.Pawn, 1000);
    }
}

state Fallback extends MoveToGoalWithEnemy
{
    function MayFall()
    {
        Pawn.bCanJump =
            (MoveTarget != None && (MoveTarget.Physics != PHYS_Falling || Pickup(MoveTarget) == None));
    }

Begin:
    SwitchToBestWeapon();
    WaitForLanding();

Moving:
    if(InventorySpot(MoveTarget) != None)
        MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(Self, 0);

    MoveToward(MoveTarget, FaceActor(1),, ShouldStrafeTo(MoveTarget));
    WhatToDoNext(14);

    if(bSoaking)
        SoakStop("STUCK IN FALLBACK!");

    GoalString $= " STUCK IN FALLBACK!";
}

state Charging
{
ignores SeePlayer, HearNoise;

    function MayFall()
    {
        if(MoveTarget != Enemy)
            return;

        Pawn.bCanJump = ShouldCharge(Enemy);
        if(!Pawn.bCanJump)
            MoveTimer = -1.0;
    }
}

defaultproperties
{
    MasterFollowDistance=1024.000000
    MaxSearchingStuckTime=120.000000
}
