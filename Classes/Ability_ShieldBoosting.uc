class Ability_ShieldBoosting extends RPGAbility;

var() float ShieldBoostingPercent;

defaultproperties
{
    GrantItem(0)=(Level=2,InventoryClass=Class'Artifact_ShieldBlast')
    ShieldBoostingPercent=3.000000
    AbilityName="Shield Boosting"
    Description="Allows the Engineer Link Gun to boost other teammates' shields."
    LevelDescription(0)="Level 1 enables the Engineer Link Gun's alt fire to boost shields."
    LevelDescription(1)="Level 2 doubles the experience for shield boosting."
    LevelDescription(2)="Level 3 tripes the experience."
    StartingCost=10
    CostAddPerLevel=5
    MaxLevel=3
    Category=class'AbilityCategory_Engineer'
}
