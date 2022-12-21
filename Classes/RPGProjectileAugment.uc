//=============================================================================
// RPGProjectileAugment.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

// an actor which is assigned to a projectile and can add more advanced behavior
class RPGProjectileAugment extends Actor;

var Projectile Proj;
var Controller InstigatorController;

var int ModFlag;

var float Modifier;

static function RPGProjectileAugment GetFor(Projectile P)
{
    local RPGProjectileAugment A;

    foreach P.ChildActors(class'RPGProjectileAugment', A)
        if(A.Class == default.Class)
            return A;

    return None;
}

static function RPGProjectileAugment Create(Projectile P, float Modifier, int ModFlag)
{
    local RPGProjectileAugment A;

    A = static.GetFor(P);
    if(A != None)
    {
        A.StopEffect();
        A.Modifier = Modifier;
        return A;
    }

    A = P.Spawn(default.Class, P,, P.Location, P.Rotation);
    A.Proj = P;
    A.Modifier = Modifier;
    A.ModFlag = ModFlag;
    A.SetBase(P);
    return A;
}

event PostBeginPlay()
{
    Proj = Projectile(Owner);
    if(Proj.Instigator != None)
    {
        Instigator = Proj.Instigator;
        InstigatorController = Instigator.Controller;
    }
    SetBase(Proj);
}

event BaseChange()
{
    if(Proj != None && Base != Proj)
    {
        if(Proj.bPendingDelete)
        {
            Explode();
            Destroy();
        }
        else
        {
            SetBase(Proj);
            return;
        }
    }
}

event Tick(float dt)
{
    if(Proj == None)
    {
        StopEffect();
        Destroy();
    }
}

function StartEffect();
function StopEffect();

function Explode()
{
    local FlakChunk F;

    if(Proj.Class == class'FlakShell')
    {
        foreach Proj.RadiusActors(class'FlakChunk', F, 12)
        {
            if(
                F.Instigator == Proj.Instigator
                && F.bTicked != Proj.bTicked //just spawned
            )
            {
                F.SetPropertyText("Tag", string(int(string(F.Tag)) | ModFlag));
            }
        }
    }
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
    bSkipActorPropertyReplication=True
    bReplicateMovement=False
}
