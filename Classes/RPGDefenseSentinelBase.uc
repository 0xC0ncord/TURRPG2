//=============================================================================
// RPGDefenseSentinelBase.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGDefenseSentinelBase extends ASTurret_Base;

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretBase'
    DrawScale=0.140000
    Skins(0)=FinalBlend'DefensePanFinal'
    Skins(1)=FinalBlend'DefensePanFinal'
    AmbientGlow=1
    CollisionRadius=30.000000
    CollisionHeight=70.000000
}
