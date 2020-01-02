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

