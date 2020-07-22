//=============================================================================
// DamTypeRetaliation.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeRetaliation extends RPGDamageType
    abstract;

defaultproperties {
    StatWeapon=class'DummyWeapon_Retaliation'
    DeathString="%k's strike back was too much for %o."
    bArmorStops=False
    bCausesBlood=False
    bExtraMomentumZ=False
}
