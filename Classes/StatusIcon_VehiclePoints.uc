class StatusIcon_VehiclePoints extends RPGStatusIcon;

function bool IsVisible()
{
    return true;
}

function string GetText()
{
    return RPRI.VehiclePoints $ "/" $ RPRI.MaxVehiclePoints;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.VehiclePointsIcon'
}
