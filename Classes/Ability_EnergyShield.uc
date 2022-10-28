class Ability_EnergyShield extends RPGAbility;

var int HealthLimit;
var int DeathPreventionCooldown;
var float NextDeathPreventionTime;

function bool PreventDeath(
    Pawn Killed,
    Controller Killer,
    class<DamageType> DamageType,
    vector HitLocation,
    bool bAlreadyPrevented
)
{
    local int DamageCouldHeal;
    local int AdrenalineReqd;

    if(Killed != RPRI.Controller.Pawn)
        return false;

    // just prevented death, wait a bit
    if(Level.TimeSeconds < NextDeathPreventionTime)
        return false;

    DamageCouldHeal = Killed.Controller.Adrenaline * BonusPerLevel * AbilityLevel;
    AdrenalineReqd = Killed.Controller.Adrenaline;
    // is this enough?
    if(Killed.Health <= 0 && DamageCouldHeal + Killed.Health > 0)
    {
        // we can save them
        if(DamageCouldHeal + Killed.Health > HealthLimit)
        {
            DamageCouldHeal = HealthLimit - Killed.Health;
            AdrenalineReqd = DamageCouldHeal / (BonusPerLevel * AbilityLevel);
        }
        Killed.Controller.Adrenaline -= AdrenalineReqd;
        Killed.Health += DamageCouldHeal;

        NextDeathPreventionTime = Level.TimeSeconds + DeathPreventionCooldown;

        return true;
    }

    // he is dead, so keep the adrenaline
    return false;
}

function AdjustPlayerDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Injured,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    local int iCount;
    local float AdrenalineReqd;
    local int DamageAbsorbed;
    local int DamageLeft;

    if(Injured != RPRI.Controller.Pawn)
        return;

    if(Damage <= 0 || Damage <= Injured.Health - HealthLimit)
        return; // nothing to do

    // first take damage off shield
    if(DamageType.default.bArmorStops)
    {
        iCount = 0;
        while(Damage > 0 && Injured.ShieldStrength > 0 && iCount < 50)
        {
            Damage = Injured.ShieldAbsorb(Damage);  // take some more shield off
            iCount++;                               // safety just in case
        }
    }

    // then see if damage would take the player below the kick-in health. If so, absorb with adrenaline
    if(Damage <= 0 || Damage <= Injured.Health - HealthLimit)
        return; // nothing to do. Just take any remaining damge if any

    // let's take off what extra damage we can
    if(Injured.Health <= HealthLimit)
        DamageLeft = 0;
    else
        DamageLeft = Injured.Health - HealthLimit; // this is how much we should let pass through
    DamageAbsorbed = Damage - DamageLeft;          // how much we need to absorb

    // now can we absorb that much
    AdrenalineReqd = DamageAbsorbed / (BonusPerLevel * AbilityLevel);

    if(Injured.Controller.Adrenaline > AdrenalineReqd)
    {
        Injured.Controller.Adrenaline -= AdrenalineReqd;
        Damage = DamageLeft;
    }
    else
    {
        // not enough - have to pass more damage through
        DamageAbsorbed = Injured.Controller.Adrenaline * BonusPerLevel * AbilityLevel;
        Injured.Controller.Adrenaline = 0;
        Damage -= DamageAbsorbed;
    }

    // leave the rest of the damage to be processed normally
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", DeathPreventionCooldown);
}

defaultproperties
{
    HealthLimit=5
    BonusPerLevel=1.000000
    DeathPreventionCooldown=10
    AbilityName="Energy Shield"
    Description="This ability causes adrenaline to be used as shields. Any incoming damage will be reduced so long as you have enough adrenaline to absorb the damage. Additionally, any damage that would cause you to be killed may also be absorbed and allow you to survive. However, this death-preventing effect may only occur once every $1 seconds."
    StartingCost=15
    MaxLevel=4
    Category=class'AbilityCategory_Adrenaline'
}
