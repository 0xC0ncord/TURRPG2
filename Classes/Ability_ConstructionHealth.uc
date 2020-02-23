class Ability_ConstructionHealth extends RPGAbility;

function ModifyConstruction(Pawn Other)
{
    local float HealthFraction;

    HealthFraction = Other.Health / Other.HealthMax;;

    Other.HealthMax = Other.default.HealthMax * (1 + (BonusPerLevel * AbilityLevel));
    Other.SuperHealthMax = Other.default.SuperHealthMax * (1 + (BonusPerLevel * AbilityLevel));
    Other.Health = Other.HealthMax * HealthFraction;
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=0.20
    AbilityName="Composite Alloys"
    Description="Gives an additional health bonus to your summoned constructions. Each level adds $1 health to your constructions' max health."
    StartingCost=2
    CostAddPerLevel=1
    MaxLevel=20
    Category=class'AbilityCategory_Engineer'
}
