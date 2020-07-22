//=============================================================================
// EngineerWeaponLockerPawn.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EngineerWeaponLockerPawn extends RPGBlock;

var EngineerWeaponLocker Locker;

function PreBeginPlay()
{
    local vector HitLocation, HitNormal;

    Super.PreBeginPlay();

    Trace(HitLocation, HitNormal, Location - vect(0,0,4000));
    if(HitLocation != vect(0,0,0) && SetLocation(HitLocation + vect(0,0,1) * (CollisionHeight + 1)))
    {
        Locker = Spawn(class'EngineerWeaponLocker',self,,Location - vect(0,0,4) + vect(0,0,1) * class'EngineerWeaponLocker'.default.CollisionHeight);
        if(Locker != None)
            return;
    }
    Destroy();
}

simulated function PostBeginPlay()
{
    Super(Pawn).PostBeginPlay();
}

simulated function Destroyed()
{
    Super(Pawn).Destroyed();
    if(Locker != None)
        Locker.Destroy();
}

singular event BaseChange()
{
    Super(Pawn).BaseChange();
}

defaultproperties
{
    DrawType=DT_None
    bBlockZeroExtentTraces=True
    bBlockNonZeroExtentTraces=True
    bBlockActors=False
    bBlockPlayers=False
    bBlockKarma=False
    bProjTarget=False
    bUseCollisionStaticMesh=False
    CollisionRadius=+80.0
    CollisionHeight=+6.0
    Physics=PHYS_None
    StaticMesh=StaticMesh'NewWeaponStatic.WeaponLockerM'
    DrawScale=+0.5
    DrawScale3D=(X=1.25,Y=1.25,Z=1.0)
    PrePivot=(X=0,Y=0,Z=105.0)
    NetUpdateFrequency=1.0
}
