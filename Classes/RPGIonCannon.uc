//=============================================================================
// RPGIonCannon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGIonCannon extends ASTurret_IonCannon
    cacheexempt;

function bool HasUDamage()
{
    return (Driver != None && Driver.HasUDamage());
}

defaultproperties
{
     TurretBaseClass=Class'RPGIonCannonBase'
     TurretSwivelClass=Class'RPGIonCannonSwivel'
     RotPitchConstraint=(Min=12084.000000)
     CamRelLocation=(Z=100.000000)
     CamDistance=(X=-200.000000)
     DefaultWeaponClassName=""
     VehicleProjSpawnOffset=(X=110.000000,Z=30.000000)
     ExitPositions(0)=(X=0.000000,Y=100.000000,Z=100.000000)
     ExitPositions(1)=(X=0.000000,Y=-100.000000,Z=100.000000)
     EntryPosition=(X=0.000000,Y=0.000000,Z=0.000000)
     FPCamPos=(X=100.000000,Z=100.000000)
     HealthMax=900.000000
     Health=900
     DrawScale=0.150000
     CollisionRadius=52.000000
     CollisionHeight=80.000000
}
