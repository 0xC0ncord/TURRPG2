//=============================================================================
// DamTypeFlakBomb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeFlakBomb extends RPGAdrenalineDamageType
    abstract;

defaultproperties {
    StatWeapon=Class'DummyWeapon_FlakBomb'
    DeathString="%o was ate some flak from %k's flak bomb."
    MaleSuicide="%o ate his own flak."
    FemaleSuicide="%o was ate her own flak."

    GibPerterbation=0.25
    bDetonatesGoop=true
    bThrowRagdoll=true
}
