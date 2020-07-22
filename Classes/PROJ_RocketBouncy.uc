//=============================================================================
// PROJ_RocketBouncy.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class PROJ_RocketBouncy extends RPGRocketProj;

simulated event HitWall(vector HitNormal, actor Wall)
{
    if(!class'WeaponModifier_Bounce'.static.Bounce(Self, HitNormal, Wall))
        Super.HitWall(HitNormal, Wall);
}

defaultproperties
{
    Buoyancy=1.00 //abused as bounciness
    LifeSpan=13.33
}
