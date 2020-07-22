//=============================================================================
// DamTypePoison.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypePoison extends RPGDamageType
    abstract;

defaultproperties {
    StatWeapon=class'DummyWeapon_Poison'
    DeathString="%o couldn't find an antidote for %k's poison."
    FemaleSuicide="%o poisoned herself."
    MaleSuicide="%o poisoned himself."
    bArmorStops=False
    bCausesBlood=False
    bExtraMomentumZ=False
    bDelayedDamage=True
}
