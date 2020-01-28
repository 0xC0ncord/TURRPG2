class WeaponModifier_Medic extends WeaponModifier_Heal;

function WeaponFire(byte Mode) {
    Identify();
}

function RPGTick(float dt)
{
    //TODO: Find a way for ballistic weapons
    Weapon.MaxOutAmmo();
}

function int GetMaxHealthBonus() {
    local Ability_LoadedMedic LM;

    if(RPRI != None)
    {
        LM = Ability_LoadedMedic(RPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
        if(LM != None)
            return LM.GetHealMax();
    }

    return Super.GetMaxHealthBonus();
}

simulated function BuildDescription() {
    Super.BuildDescription();
    AddToDescription(class'WeaponModifier_Infinity'.default.InfAmmoText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, class'WeaponModifier_Infinity'.default.InfAmmoText);

    return Description;
}

defaultproperties {
    HealText="$1 healing"
    bOmitModifierInName=True

    bAllowForSpecials=False
    bCanThrow=False

    MinModifier=6
    MaxModifier=6
    AIRatingBonus=0.100000
    PatternPos="Medic $W of Infinity"
}
