//=============================================================================
// MoteBase.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MoteBase extends Actor;

var Controller PlayerSpawner;
var int TeamNum;
var float EffectModifier;
var float EffectDuration;
var float PickupRadius;
var float SecondsUntilGone;

var float Speed;

var class<Effect_Mote> EffectClass;
var class<RPGEmitter> EmitterClass;

var RPGEmitter FX;
var Pawn Target;
var float DissipateTime;
var float ToDestVelocity;
var float Alpha;

replication
{
    reliable if(Role == ROLE_Authority)
        Target;
}

simulated function PostBeginPlay()
{
    ToDestVelocity = 850.0 + (float(100) * FRand());
    if(Role == ROLE_Authority)
        DissipateTime = Level.TimeSeconds + SecondsUntilGone;
}

simulated function PostNetBeginPlay()
{
    if(Level.NetMode != NM_DedicatedServer)
        FX = Spawn(EmitterClass, self,, Location);
}

simulated function Destroyed()
{
    if(FX != None)
        FX.Kill();
}

function ServerReachedDest()
{
    local Effect_Mote Effect;

    if(PlayerController(Target.Controller) != None)
        PlayerController(Target.Controller).ClientFlash(0.80, vect(600, 0, 300));

    Effect = Effect_Mote(EffectClass.static.Create(Target, PlayerSpawner, EffectClass.default.Duration, EffectModifier));
    if(Effect != None)
    {
        if(Effect.Source != None)
        {
            Effect.bConvertToSource = true;
            Effect.Source = None;
        }
        Effect.bIsSource = true;
        Effect.Start();
    }
}

simulated function Tick(float dt)
{
    local Controller C;
    local vector ToDest, V;

    if(Role == ROLE_Authority)
    {
        if(PlayerSpawner == None || PlayerSpawner.GetTeamNum() != TeamNum)
        {
            Destroy();
            return;
        }

        //if the one picking us up died or is too far away
        if(
            Target != None
            && (
                Target.Health <= 0
                || VSize(Target.Location - Location) > PickupRadius
            )
        )
        {
            Target = None;
        }

        //find someone new
        if(Target == None)
        {
            for(C = Level.ControllerList; C != None; C = C.NextController)
            {
                if(
                    C.Pawn != None
                    && C.Pawn.Health > 0
                    && class'Util'.static.SameTeamC(C, PlayerSpawner)
                    && VSize(C.Pawn.Location - Location) <= PickupRadius
                    && FastTrace(C.Pawn.Location, Location)
                )
                {
                    DissipateTime = 0;
                    Target = C.Pawn;
                    break;
                }
            }
        }
    }

    if(Target == None)
    {
        if(Role == ROLE_Authority)
        {
            if(DissipateTime == 0)
                DissipateTime = Level.TimeSeconds + SecondsUntilGone;
            else if(DissipateTime <= Level.TimeSeconds)
                Destroy();
        }
        return;
    }

    Alpha += (dt * 0.80);
    if(Alpha > 1.0)
        Alpha = 1.0;

    ToDest = Target.Location - Location;

    if(Role == ROLE_Authority)
    {
        if(VSize(ToDest) < float(20))
        {
            ServerReachedDest();
            Destroy();
            return;
        }
    }

    V = ((Velocity * (1.0 - Alpha)) + ((ToDestVelocity * Normal(ToDest)) * Alpha)) + (VRand() * float(40));
    Velocity += (Acceleration * dt);
    if(VSize(V) > float(950))
        V = float(950) * Normal(V);

    SetLocation(Location + (V * dt));
}

defaultproperties
{
    EffectModifier=0.1
    PickupRadius=768.0
    EffectDuration=8.0
    SecondsUntilGone=12.0
    bHidden=True
    bAcceptsProjectors=False
    bReplicateMovement=False
    Physics=PHYS_Projectile
    RemoteRole=ROLE_SimulatedProxy
    bCollideWorld=True
    CollisionRadius=16.000000
    CollisionHeight=12.000000
    bFixedRotationDir=True
}
