//=============================================================================
// PROJ_FlakShellBouncy.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class PROJ_FlakShellBouncy extends FlakShell;

simulated event HitWall(vector HitNormal, actor Wall)
{
    if(!class'WeaponModifier_Bounce'.static.Bounce(Self, HitNormal, Wall))
        Super.HitWall(HitNormal, Wall);
}

defaultproperties
{
    bBounce=True
    Buoyancy=0.75 //abused as bounciness
    LifeSpan=10.00
}
