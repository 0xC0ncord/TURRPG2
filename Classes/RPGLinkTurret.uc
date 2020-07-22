//=============================================================================
// RPGLinkTurret.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGLinkTurret extends ASTurret_LinkTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    DefaultWeaponClassName=string(class'Weapon_RPGLinkTurret');

    super.PostBeginPlay();
}

function bool HasUDamage()
{
    return (Driver != None && Driver.HasUDamage());
}

defaultproperties
{
     AutoTurretControllerClass=None
     TurretBaseClass=class'RPGLinkTurretBase'
     TurretSwivelClass=class'RPGLinkTurretSwivel'
     DefaultWeaponClassName=""
     VehicleProjSpawnOffset=(X=170.000000)
     bRelativeExitPos=True
     ExitPositions(0)=(Y=100.000000,Z=100.000000)
     ExitPositions(1)=(Y=-100.000000,Z=100.000000)
     EntryRadius=120.000000
     DrawScale=0.200000
     CollisionRadius=60.000000
     CollisionHeight=90.000000
}
