//=============================================================================
// RPGMinigunTurret_Auto.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMinigunTurret_Auto extends RPGMinigunTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    DefaultWeaponClassName=string(class'Weapon_Turret_Minigun');
    Super(ASTurret_Minigun).PostBeginPlay();
}

function vector GetBotError(vector StartLocation)
{
    return vect(0,0,0);
}

defaultproperties
{
    bNonHumanControl=True
    bAutoTurret=True
}
