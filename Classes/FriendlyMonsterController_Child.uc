//=============================================================================
// FriendlyMonsterController_Child.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FriendlyMonsterController_Child extends FriendlyMonsterController;

var Pawn Parent;

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
        FindNewEnemy();

    if(Enemy != None)
        ChooseAttackMode();
    else if(Parent != None)
        FollowMaster();
    else
    {
        GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
        WanderOrCamp(true);
    }
}

function FollowMaster() //follow parent instead of master
{
    if(
        VSize(Parent.Location - Pawn.Location) > MasterFollowDistance ||
        VSize(Parent.Velocity) > Parent.WalkingPct * Parent.GroundSpeed ||
        !LineOfSightTo(Parent)
    )
    {
        GoalString = "Follow Master "$Master.PlayerReplicationInfo.PlayerName;

        if(FindBestPathToward(Parent, false, Pawn.bCanPickupInventory))
        {
            GotoState('Roaming');
            return;
        }
    }

    GoalString = "Wander or Camp at "$Level.TimeSeconds;
    WanderOrCamp(true);
    CurrentSearchDestination = None;
}

function SearchAndDestroyCommand(); //do nothing
function SearchAndDestroy();

defaultproperties
{
}
