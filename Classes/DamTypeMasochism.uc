//=============================================================================
// DamTypeMasochism.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeMasochism extends RPGDamageType
    abstract;

var localized string MaleSuicides[3], FemaleSuicides[3];

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
    return static.SuicideMessage(Victim);
}

static function string SuicideMessage(PlayerReplicationInfo Victim)
{
    if ( Victim.bIsFemale )
        return default.FemaleSuicides[Rand(3)];
    else
        return default.MaleSuicides[Rand(3)];
}

defaultproperties {
    StatWeapon=class'DummyWeapon_Masochism'
    MaleSuicides(0)="%o had too much fun with pain."
    MaleSuicides(1)="%o endured more than he could handle."
    FemaleSuicides(0)="%o had too much fun with pain."
    FemaleSuicides(1)="%o endured more than she could handle."
    bArmorStops=False
    bLocationalHit=False
    bAlwaysSevers=True
    GibPerterbation=1.000000
}
