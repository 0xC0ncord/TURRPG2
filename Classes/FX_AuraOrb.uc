//=============================================================================
// FX_AuraOrb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AuraOrb extends Emitter;

var float Speed;
var Pawn Target;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Target;
}

simulated function PostBeginPlay()
{
    Velocity = Speed * vector(Rotation);
    SetTimer(0.05, true);
}

simulated function Timer()
{
    local vector Dir;
    local vector ForceDir;
    local float VelMag;

    if(Target == None)
    {
        SetTimer(0.0, false);
        Destroy();
        return;
    }
    else if(VSize(Target.Location - Location) < FMax(Speed * TimerRate, Target.CollisionRadius))
    {
        SetTimer(0.0, false);
        Kill();
        return;
    }

    Dir = Target.Location - Location;
    VelMag = VSize(Velocity);
    ForceDir = Normal((Dir + Target.Velocity * VSize(Dir) / (VelMag * 2)) * 0.8 * VelMag + Velocity);
    Velocity = VelMag * ForceDir;
}

defaultproperties
{
    Speed=2400.0
    AutoDestroy=True
    bNoDelete=False
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=True
    bNetInitialRotation=True
    bNotOnDedServer=False
    Physics=PHYS_Projectile
    LifeSpan=4.0
}
