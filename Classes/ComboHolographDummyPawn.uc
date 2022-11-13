//=============================================================================
// ComboHolographDummyPawn.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboHolographDummyPawn extends xPawn;

var float AttractRadius;

simulated function PostBeginPlay()
{
    SetPhysics(PHYS_Falling);

    if(Role == ROLE_Authority)
    {
        Controller = Spawn(class'ComboHolographDummyController', self,, Location, Rotation);
        if(Controller != None)
            Controller.Possess(Self);
    }
}

function PossessedBy(Controller C)
{
    Controller = C;
}

simulated function Landed( Vector HitNormal )
{
    SetPhysics(PHYS_None);
    SetLocation(Location + vect(0, 0, 0));
    SetCollision(false, false, false);
    SetDrawScale(1.000000);
    bCanWalk = false;
    bCanFly = false;
    bCanSwim = false;
    bMovable = false;
    GroundSpeed = 0;
    WaterSpeed = 0;
    AirSpeed = 0;
    AirControl = 0;
    JumpZ = 0;
    bJumpCapable = false;
}

function Tick(float dt)
{
    local Monster M;

    foreach VisibleCollidingActors(class'Monster', M, AttractRadius)
    {
        if(M != None && M.Health > 0 && M.MaxFallSpeed != 100000)
        {
            if(MonsterController(M.Controller) != None && FriendlyMonsterController(M.Controller) == None && M.Controller.Enemy != Self)
            {
                MonsterController(M.Controller).ChangeEnemy(Self, true);
            }
        }
    }
}

simulated function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType)
{
}

simulated function FootStepping(int Side)
{
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
}

simulated function PlayDoubleJump()
{
}

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
}

event bool EncroachingOn( actor Other )
{
    return true;
}

event EncroachedBy( actor Other )
{
}

function gibbedBy(actor Other)
{
}

simulated singular function Touch(Actor Other)
{
}

defaultproperties
{
    AttractRadius=1500.000000
    bCanDodgeDoubleJump=False
    SoundFootsteps(0)=None
    SoundFootsteps(1)=None
    SoundFootsteps(2)=None
    SoundFootsteps(3)=None
    SoundFootsteps(4)=None
    SoundFootsteps(5)=None
    SoundFootsteps(6)=None
    SoundFootsteps(7)=None
    SoundFootsteps(8)=None
    SoundFootsteps(9)=None
    SoundFootsteps(10)=None
    RagImpactSounds(0)=None
    RagImpactSounds(1)=None
    RagImpactSounds(2)=None
    bCanCrouch=False
    bCanWallDodge=False
    bCanPickupInventory=False
    bCanUse=False
    Health=1000000000
    Physics=PHYS_Falling
    NetUpdateFrequency=8.000000
    Mesh=SkeletalMesh'Bot.BotB'
    DrawScale=0.000001
    Skins(0)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
    Skins(1)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
    bCanBeDamaged=False
    bOwnerNoSee=False
    bHardAttach=True
    CollisionRadius=25.000000
    CollisionHeight=44.000000
    bCollideActors=False
    bBlockZeroExtentTraces=False
    bBlockNonZeroExtentTraces=False
    bProjTarget=False
}
