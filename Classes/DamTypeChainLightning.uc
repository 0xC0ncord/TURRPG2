class DamTypeChainLightning extends RPGAdrenalineDamageType
    abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth)
{
    HitEffects[0] = class'HitSmoke';
    if (Rand(25) > VictemHealth)
        HitEffects[1] = class'HitFlame';
}

defaultproperties
{
    DeathString="%o was electrocuted by %k's chain lightning."
    FemaleSuicide="%o had an electrifying experience."
    MaleSuicide="%o had an electrifying experience."
    StatWeapon=class'DummyWeapon_ChainLightning'
    bCauseConvulsions=True
    bSuperWeapon=True
    DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
    DamageOverlayTime=1.000000
    GibPerterbation=0.250000
}
