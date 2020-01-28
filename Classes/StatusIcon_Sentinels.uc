class StatusIcon_Sentinels extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumSentinels > 0);
}

function string GetText()
{
    return RPRI.NumSentinels $ "/" $ RPRI.MaxSentinels;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.SentinelIcon'
}
