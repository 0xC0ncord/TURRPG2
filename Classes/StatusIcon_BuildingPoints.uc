class StatusIcon_BuildingPoints extends RPGStatusIcon;

function bool IsVisible()
{
    return true;
}

function string GetText()
{
    return RPRI.BuildingPoints $ "/" $ RPRI.MaxBuildingPoints;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.BuildingPointsIcon'
}
