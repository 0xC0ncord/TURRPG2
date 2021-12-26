//=============================================================================
// DamTypeComboSiphon.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeComboSiphon extends RPGDamageType
    abstract;

defaultproperties
{
    DeathString="%o had their life force drained by %k's siphon combo."
    FemaleSuicide="%o sucked herself out of existence."
    MaleSuicide="%o sucked himself out of existence."
    StatWeapon=class'DummyWeapon_ComboSiphon'
    bArmorStops=False
    bLocationalHit=False
    bCausesBlood=False
    bExtraMomentumZ=False
}
