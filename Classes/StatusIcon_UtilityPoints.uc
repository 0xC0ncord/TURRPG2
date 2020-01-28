class StatusIcon_UtilityPoints extends RPGStatusIcon;

function bool IsVisible()
{
    return true;
}

function string GetText()
{
    return RPRI.UtilityPoints $ "/" $ RPRI.MaxUtilityPoints;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.UtilityPointsIcon'
}
