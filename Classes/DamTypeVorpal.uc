//=============================================================================
// DamTypeVorpal.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeVorpal extends RPGDamageType
    abstract;

defaultproperties {
    StatWeapon=Class'DummyWeapon_Vorpal'
    DeathString="%o was instantly killed by %k's Vorpal weapon."
    FemaleSuicide="%o was instantly killed by her own Vorpal weapon."
    MaleSuicide="%o was instantly killed by his own Vorpal weapon."
}
