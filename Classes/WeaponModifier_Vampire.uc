class WeaponModifier_Vampire extends RPGWeaponModifier;

var config float VampireMaxHealth;

var float RealHealthGain;

var localized string VampireText, MasochismText;

function StartEffect() {
    Super.StartEffect();
    RealHealthGain = 0; //reset when drawn
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    local int Health;
    local float x;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if(class'DevoidEffect_Vampire'.static.CanBeApplied(Injured, InstigatedBy.Controller)) {
        x = FMax(0, FMin(Injured.Health, float(Damage) * BonusPerLevel * float(Modifier)));
        RealHealthGain += x;

        if(Abs(RealHealthGain) > 1) {
            Health = int(RealHealthGain);
            RealHealthGain -= float(Health); //keep fraction

            if(Modifier > 0) {
                Identify();
                Instigator.GiveHealth(Health, Instigator.HealthMax * VampireMaxHealth);
            } else if(Modifier < 0) {
                Identify();
                Instigator.TakeDamage(Health, Instigator, Instigator.Location, vect(0, 0, 0), class'DamTypeMasochism');
            }
        }
    }
}

simulated function BuildDescription() {
    Super.BuildDescription();

    if(Modifier >= 0) {
        AddToDescription(VampireText, BonusPerLevel);
    } else {
        AddToDescription(MasochismText, -BonusPerLevel);
    }
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    if(Modifier >= 0)
        StaticAddToDescription(Description, Modifier, default.VampireText, default.BonusPerLevel);
    else
        StaticAddToDescription(Description, Modifier, default.MasochismText, -default.BonusPerLevel);

    return Description;
}

defaultproperties
{
    VampireText="$1 self-healing for dmg"
    MasochismText="$1 self-damage"
    DamageBonus=0.04
    BonusPerLevel=0.0375 //VampireAmount * 0.05
    VampireMaxHealth=1.333333 //the good old 33%
    MinModifier=-6
    MaxModifier=8
    bCanHaveZeroModifier=False
    ModifierOverlay=Shader'WeaponSkins.ShockLaser.LaserShader'
    PatternPos="Vampiric $W"
    PatternNeg="$W of Masochism"
    //AI
    AIRatingBonus=0.075
}
