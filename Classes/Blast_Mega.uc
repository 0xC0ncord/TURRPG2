class Blast_Mega extends Blast_Ultima;

defaultproperties
{
    bIgnoreUltimaShield=True
    bIgnoreProtectionGun=True

    bAffectInstigator=False
    bAllowDeadInstigator=False

    Radius=2500.000000

    Damage=360.000000
    DamageStages=5

    DamageType=class'DamTypeMegaExplosion'
    ChargeEmitterClass=class'FX_BlastCharger_Mega_NEW'
    ExplosionClass=class'FX_BlastExplosion_Mega_NEW'
}
