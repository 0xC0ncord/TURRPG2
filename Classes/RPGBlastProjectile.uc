//=============================================================================
// RPGBlastProjectile.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlastProjectile extends Projectile;

var class<Blast> BlastClass;
var class<Emitter> TrailClass;
var float BlastDistance;

var vector SpawnLocation;

var Emitter Trail;
var bool bDidEffect;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        BlastDistance, SpawnLocation;
}

function PreBeginPlay()
{
    BlastDistance = BlastClass.default.Radius;
    SpawnLocation = Location;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    Velocity = vector(Rotation);
    Velocity *= Speed;
}

simulated function Destroyed()
{
    if(Trail != None)
        Trail.Kill();

    if(Role == ROLE_Authority)
        DoEffect();

    Super.Destroyed();
}

simulated function Tick(float dt)
{
    if(BlastDistance > 0 && VSize(SpawnLocation - Location) >= BlastDistance)
        Destroy();
}

simulated function PostNetBeginPlay()
{
    if(Level.NetMode != NM_DedicatedServer)
        Trail = Spawn(TrailClass, self);
}

simulated function ProcessTouch(Actor Other, vector HitLocation);

simulated function HitWall(vector HitNormal, Actor Wall)
{
    Destroy();
}

function DoEffect()
{
    if(bDidEffect)
        return;
    bDidEffect = true;

    SpawnBlast();
}

function Blast SpawnBlast()
{
    local Blast Blast;

    Blast = Instigator.Spawn(BlastClass, Instigator.Controller,, Location);
    Blast.SetChargeTime(Blast.ChargeTime - (default.LifeSpan - LifeSpan));

    return Blast;
}

defaultproperties
{
    BlastDistance=1500.000000
    Speed=5000.000000
    MaxSpeed=5000.000000
    Damage=0.000000
    DamageRadius=0.000000
    DrawType=DT_None
    LifeSpan=3.000000
    CollisionHeight=8.000000
    CollisionRadius=8.000000
}
