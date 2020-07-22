//=============================================================================
// RPGCeilingDefenseSentinel.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGCeilingDefenseSentinel extends RPGDefenseSentinel
    cacheexempt;

defaultproperties
{
     TurretBaseClass=None
     VehicleNameString="Ceiling Defense Sentinel"
     Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'
     DrawScale=0.300000
     Skins(0)=Combiner'CeilingDefense_C'
     Skins(1)=Combiner'CeilingDefense_C'
     CollisionRadius=45.000000
     CollisionHeight=60.000000
}
