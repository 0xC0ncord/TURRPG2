class StatusIcon_SentinelPoints extends RPGStatusIcon;

function bool IsVisible()
{
    return true;
}

function string GetText()
{
    return RPRI.SentinelPoints $ "/" $ RPRI.MaxSentinelPoints;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.SentinelPointsIcon'
}
