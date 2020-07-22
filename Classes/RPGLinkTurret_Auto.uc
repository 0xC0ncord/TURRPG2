//=============================================================================
// RPGLinkTurret_Auto.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGLinkTurret_Auto extends RPGLinkTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    TurretBaseClass=class'RPGLinkTurretBase';
    TurretSwivelClass=class'RPGLinkTurretSwivel';
    DefaultWeaponClassName=string(class'Weapon_LinkTurret');

    Super(ASTurret_LinkTurret).PostBeginPlay();
}

defaultproperties
{
    bNonHumanControl=True
    bAutoTurret=True
}
