class StatusIcon_TurretPoints extends RPGStatusIcon;

function bool IsVisible()
{
    return true;
}

function string GetText()
{
    return RPRI.TurretPoints $ "/" $ RPRI.MaxTurretPoints;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.TurretPointsIcon'
}
