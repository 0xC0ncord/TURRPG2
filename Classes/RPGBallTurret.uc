//=============================================================================
// RPGBallTurret.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBallTurret extends ASTurret_BallTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    DefaultWeaponClassName = string(class'Weapon_RPGBallTurret');
}

function bool HasUDamage()
{
    return (Driver != None && Driver.HasUDamage());
}

defaultproperties
{
     AutoTurretControllerClass=None
     RotPitchConstraint=(Min=7000.000000,Max=2048.000000)
     CamAbsLocation=(Z=50.000000)
     CamRelLocation=(X=100.000000,Z=50.000000)
     CamDistance=(X=-400.000000,Z=50.000000)
     DefaultWeaponClassName=""
     bRelativeExitPos=True
     ExitPositions(0)=(Y=100.000000,Z=100.000000)
     ExitPositions(1)=(Y=-100.000000,Z=100.000000)
     EntryRadius=120.000000
     FPCamPos=(X=-25.000000,Y=13.000000,Z=93.000000)
     VehicleNameString="Ball Turret"
}
