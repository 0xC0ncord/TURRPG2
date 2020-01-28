class RPGMinigunTurret_Auto extends RPGMinigunTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    DefaultWeaponClassName=string(class'Weapon_Turret_Minigun');
    Super(ASTurret_Minigun).PostBeginPlay();
}

function vector GetBotError(vector StartLocation)
{
    return vect(0,0,0);
}

defaultproperties
{
    bNonHumanControl=True
    bAutoTurret=True
    bNoTeamBeacon=False
}
