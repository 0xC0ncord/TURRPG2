class StatusIcon_MonsterPoints extends RPGStatusIcon;

function bool IsVisible()
{
    return true;
}

function string GetText()
{
    return RPRI.MonsterPoints $ "/" $ RPRI.MaxMonsterPoints;
}

defaultproperties
{
     IconMaterial=Texture'TURRPG2.StatusIcons.MonsterPointsIcon'
}
