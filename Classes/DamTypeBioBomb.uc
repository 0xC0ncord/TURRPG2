//=============================================================================
// DamTypeBioBomb.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeBioBomb extends RPGAdrenalineDamageType
    abstract;

defaultproperties {
    StatWeapon=Class'DummyWeapon_BioBomb'
    DeathString="%o was GOOPIFIED by %k's bio bomb."
    MaleSuicide="%o was GOOPIFIED."
    FemaleSuicide="%o was GOOPIFIED."

    bKUseTearOffMomentum=false

    DeathOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
}
