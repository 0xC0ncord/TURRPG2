class Ability_ConstructionDamage extends RPGAbility;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Vehicle(InstigatedBy) != None && Vehicle(InstigatedBy).bNonHumanControl && InstigatedBy.Controller != None)
        Damage = Damage * (1 + (BonusPerLevel * AbilityLevel));
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=0.025
    AbilityName="Improved Sentinel Munitions"
    Description="For every level of this ability, your summoned offensive sentinels gain an additional $1 damage bonus."
    StartingCost=2
    CostAddPerLevel=1
    MaxLevel=10
    Category=class'AbilityCategory_Engineer'
}
