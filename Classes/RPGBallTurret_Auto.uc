class RPGBallTurret_Auto extends RPGBallTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    DefaultWeaponClassName = string(class'UT2k4AssaultFull.Weapon_Turret');
    Super(ASTurret_BallTurret).PostBeginPlay();
}

defaultproperties
{
    bNonHumanControl=True
    bAutoTurret=True
}
