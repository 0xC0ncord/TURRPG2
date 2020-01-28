class StatusIcon_Utilities extends RPGStatusIcon;

function bool IsVisible()
{
    return (RPRI.NumUtilities > 0);
}

function string GetText()
{
    return RPRI.NumUtilities $ "/" $ RPRI.MaxUtilities;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.UtilityIcon'
}
