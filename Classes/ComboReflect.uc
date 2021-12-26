//=============================================================================
// ComboReflect.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboReflect extends RPGCombo;

var float ReflectRadius;
var float ReflectChance;

var FX_ComboReflect FX;
var FX_ComboReflect_FP FX_FP;

var array<Projectile> CheckedProjectiles;

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboReflect', P,, P.Location);
    FX_FP = Spawn(class'FX_ComboReflect_FP', P,, P.Location);
}

function DestroyEffects(Pawn P)
{
    if(FX != None)
        FX.ClientKill();
    if(FX_FP != None)
        FX_FP.ClientKill();
}

function Tick(float dt)
{
    local Pawn PawnOwner;
    local int i;
    local Projectile P;
    local class<Projectile> ProjClass;
    local vector ProjLoc;
    local vector X, RefDir, RefNormal;
    local Sync_ProjectileDestroy Sync;

    Super.Tick(dt);

    if(bPendingDelete)
        return;

    PawnOwner = Pawn(Owner);

    // clean out old projectiles
    while(i < CheckedProjectiles.Length)
    {
        if(CheckedProjectiles[i] == None)
            CheckedProjectiles.Remove(i, 1);
        else
            i++;
    }

    foreach PawnOwner.VisibleCollidingActors(class'Projectile', P, FMax(PawnOwner.CollisionHeight, PawnOwner.CollisionRadius) + ReflectRadius)
    {
        if(
            P != None
            && class'Util'.static.InArray(P, CheckedProjectiles) == -1
            && !class'Util'.static.ProjectileSameTeamC(P, PawnOwner.Controller)
        )
        {
            if(FRand() <= ReflectChance)
            {
                ProjClass = P.Class;
                ProjLoc = P.Location;

                X = Normal(P.Velocity);
                RefNormal = Normal(ProjLoc - PawnOwner.Location);
                RefDir = X - 2.0 * RefNormal * (X dot RefNormal);
                RefDir = RefNormal;

                if(P.bNetTemporary)
                {
                    Sync = PawnOwner.Spawn(class'Sync_ProjectileDestroy');
                    Sync.Proj = P;
                    Sync.ProjClass = ProjClass;
                    Sync.ProjLoc = ProjLoc;
                    Sync.ProjInstigator = P.Instigator;
                }
                else
                    P.NetUpdateTime = Level.TimeSeconds - 1;
                P.Destroy();

                PawnOwner.Spawn(ProjClass, PawnOwner,, ProjLoc + RefDir, Rotator(RefDir));
                Spawn(class'FX_ComboReflectHit',,, ProjLoc);
            }
            else
            {
                // couldn't reflect this one, so make sure we don't try it again
                CheckedProjectiles[CheckedProjectiles.Length] = P;
            }
        }
    }
}

defaultproperties
{
    ReflectRadius=96.000000
    ReflectChance=0.660000
    ExecMessage="Reflect!"
    Duration=20.000000
    ComboAnnouncementName="ComboReflect"
    keys(0)=8
    keys(1)=8
    keys(2)=2
    keys(3)=2
}
