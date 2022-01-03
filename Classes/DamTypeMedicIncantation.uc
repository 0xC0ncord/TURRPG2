//=============================================================================
// DamType_MedicIncantation.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeMedicIncantation extends RPGDamageType
    abstract;

defaultproperties
{
    StatWeapon=class'DummyWeapon_MedicIncantation'
    DeathString="%o's life force conflicted with %k's healing incantation."
    FemaleSuicide="%o recited the healing incantation incorrectly."
    MaleSuicide="%o recited the healing incantation incorrectly."
    bArmorStops=False
}
