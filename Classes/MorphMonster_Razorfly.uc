//=============================================================================
// MorphMonster_Razorfly.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Razorfly extends MorphMonster;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    PlayAnim('Fly');
}

function SetMovementPhysics()
{
    SetPhysics(PHYS_Flying);
    PlayAnim('Fly');
}

singular function Falling()
{
    SetPhysics(PHYS_Flying);
}

simulated function AnimEnd(int Channel)
{
    if ( bShotAnim )
        bShotAnim = false;
    LoopAnim('Fly',1,0.05);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    PlayAnim('Dead');
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    TweenAnim('TakeHit', 0.05);
}

function RangedAttack(Actor A)
{
    if ( A!=None && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        bShotAnim = true;
        SetAnimAction('Shoot1');
        if ( MeleeDamageTarget(10, (15000.0 * Normal(A.Location - Location))) )
            PlaySound(sound'injur1rf', SLOT_Talk);

        Controller.Destination = Location + 110 * (Normal(Location - A.Location) + VRand());
        Controller.Destination.Z = Location.Z + 70;
        Velocity = AirSpeed * normal(Controller.Destination - Location);
    }
}

simulated function PlayFlying( bool bIsMoving )
{
    PlayInAir();
}
simulated function PlayWaiting()
{
    PlayInAir();
}
simulated function PlayWalking()
{
    PlayInAir();
}
simulated function PlayRunning( byte MovementDir )
{
    PlayInAir();
}
simulated function PlayInAir()
{
    LoopAnim('Fly',,0.1);
}
simulated function PlayLandingAnimation(float ImpactVel)
{
    PlayInAir();
}
simulated function PlaySwimming()
{
    PlayInAir();
}

defaultproperties
{
     FireAnims(0)="Shoot1"
     bCanDodge=False
     bAlwaysStrafe=True
     HitSound(0)=Sound'SkaarjPack_rc.Razorfly.injur1rf'
     HitSound(1)=Sound'SkaarjPack_rc.Razorfly.injur2rf'
     HitSound(2)=Sound'SkaarjPack_rc.Razorfly.injur1rf'
     HitSound(3)=Sound'SkaarjPack_rc.Razorfly.injur2rf'
     DeathSound(0)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     DeathSound(1)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     DeathSound(2)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     DeathSound(3)=Sound'SkaarjPack_rc.Razorfly.death1rf'
     bCanFly=True
     MeleeRange=40.000000
     AirSpeed=300.000000
     AccelRate=600.000000
     Health=35
     bPhysicsAnimUpdate=False
     AmbientSound=Sound'SkaarjPack_rc.Razorfly.buzz3rf'
     Mesh=VertMesh'SkaarjPack_rc.FlyM'
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.JFly1'
     Skins(1)=FinalBlend'SkaarjPackSkins.Skins.JFly1'
     CollisionRadius=18.000000
     CollisionHeight=11.000000
     RotationRate=(Pitch=6000,Yaw=65000,Roll=8192)
}
