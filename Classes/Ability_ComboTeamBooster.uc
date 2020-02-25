class Ability_ComboTeamBooster extends RPGAbility;

defaultproperties
{
    ComboReplacements(0)=(ComboClasses=(class'ComboDefensive',class'RPGComboDefensive'),NewComboClass=class'ComboTeamBooster')
    AbilityName="Team Booster"
    Description="Replaces the Booster adrenaline combo with Team Booster, which will heal everyone on your team instead of just yourself and award experience for it."
    MaxLevel=1
    StartingCost=20
    RequiredAbilities(0)=(AbilityClass=class'Ability_LoadedMedic',Level=1)
    Category=class'AbilityCategory_Medic'
}
