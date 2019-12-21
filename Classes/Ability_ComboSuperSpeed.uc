class Ability_ComboSuperSpeed extends RPGAbility;

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(class'ComboSuperSpeed'.default.SpeedBonus));
}

defaultproperties
{
    ComboReplacements(0)=(ComboClasses=(class'ComboSpeed',class'RPGComboSpeed'),NewComboClass=class'ComboSuperSpeed')
    AbilityName="Super Speed"
    Description="Replaces the Speed adrenaline combo by Super Speed, which makes you $1 faster and has a multi-colored trail."
    MaxLevel=1
    StartingCost=40
    Category=class'AbilityCategory_Movement';
}
