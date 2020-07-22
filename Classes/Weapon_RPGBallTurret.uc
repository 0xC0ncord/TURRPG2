//=============================================================================
// Weapon_RPGBallTurret.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Weapon_RPGBallTurret extends Weapon_Turret
    cacheexempt;

defaultproperties
{
     FireModeClass(0)=Class'FM_RPGBallTurret_Fire'
}
