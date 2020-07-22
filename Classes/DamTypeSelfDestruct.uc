//=============================================================================
// DamTypeSelfDestruct.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeSelfDestruct extends RPGDamageType
    abstract;

defaultproperties {
    StatWeapon=Class'DummyWeapon_SelfDestruct'
    DeathString="%o fell victim to %k's self destructing vehicle."
    FemaleSuicide="%o wasn't quick enough to get away from her self destructing vehicle..."
    MaleSuicide="%o wasn't quick enough to get away from his self destructing vehicle..."
    bCauseConvulsions=True
    GibPerterbation=1.500000
}
