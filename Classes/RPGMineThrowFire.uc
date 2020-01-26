class RPGMineThrowFire extends ONSMineThrowFire;

var string TeamProjectileClassName[4];

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    ProjectileClass = class<Projectile>(DynamicLoadObject(TeamProjectileClassName[Weapon.Instigator.GetTeamNum()], class'Class'));
    return Super.SpawnProjectile(Start, Dir);
}

defaultproperties
{
    TeamProjectileClassName(0)="Onslaught.ONSMineProjectileRED"
    TeamProjectileClassName(1)="Onslaught.ONSMineProjectileBLUE"
    TeamProjectileClassName(2)="OLTeamGames.OLTeamsONSMineProjectileGREEN"
    TeamProjectileClassName(3)="OLTeamGames.OLTeamsONSMineProjectileGOLD"
}
