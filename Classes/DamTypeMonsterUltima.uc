//=============================================================================
// DamTypeMonsterUltima.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeMonsterUltima extends DamTypeUltima
    abstract;

defaultproperties {
    StatWeapon=class'DummyWeapon_MonsterUltima'
    DeathString="%o was PULVERIZED by the power of %k's monster ultima!"
}
