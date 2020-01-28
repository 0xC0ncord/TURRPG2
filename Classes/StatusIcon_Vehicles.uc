class StatusIcon_Vehicles extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumVehicles > 0);
}

function string GetText()
{
    return RPRI.NumVehicles $ "/" $ RPRI.MaxVehicles;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.VehicleIcon'
}
