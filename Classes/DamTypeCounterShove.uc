//=============================================================================
// DamTypeCounterShove.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeCounterShove extends RPGDamageType
    abstract;

defaultproperties {
    StatWeapon=class'DummyWeapon_CounterShove'
    DeathString="%k went up up and away, courtesy of %o's Counter Shove."
    KDamageImpulse=0.000000
}
