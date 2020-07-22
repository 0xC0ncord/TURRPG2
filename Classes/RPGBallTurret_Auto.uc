//=============================================================================
// RPGBallTurret_Auto.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBallTurret_Auto extends RPGBallTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    DefaultWeaponClassName = string(class'UT2k4AssaultFull.Weapon_Turret');
    Super(ASTurret_BallTurret).PostBeginPlay();
}

defaultproperties
{
    bNonHumanControl=True
    bAutoTurret=True
}
