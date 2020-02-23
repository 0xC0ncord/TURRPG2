class Ability_ShieldBoosting extends RPGAbility;

var() float ShieldBoostingPercent;

defaultproperties
{
    GrantItem(0)=(Level=2,InventoryClass=Class'Artifact_ShieldBlast')
    ShieldBoostingPercent=3.000000
    AbilityName="Shield Boosting"
    Description="Allows the Engineer Link Gun to boost other teammates' shields.|Level 1 enables the Engineer Link Gun's alt fire to boost shields.|Level 2 doubles the experience for shield boosting.|Level 3 triples the experience."
    StartingCost=10
    CostAddPerLevel=5
    MaxLevel=3
    Category=class'AbilityCategory_Engineer'
}
