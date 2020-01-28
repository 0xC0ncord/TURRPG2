class StatusIcon_Buildings extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumBuildings > 0);
}

function string GetText()
{
    return RPRI.NumBuildings $ "/" $ RPRI.MaxBuildings;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.BuildingIcon'
}
