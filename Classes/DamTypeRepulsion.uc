//=============================================================================
// DamTypeRepulsion.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeRepulsion extends RPGAdrenalineDamageType
    abstract;

defaultproperties {
    StatWeapon=Class'DummyWeapon_Repulsion'
    DeathString="%o threw %k out of this world."
    FemaleSuicide="%o threw herself out of this world."
    MaleSuicide="%o threw himself out of this world."
    bDelayedDamage=True
}
