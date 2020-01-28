class RPGLinkTurret_Auto extends RPGLinkTurret
    cacheexempt;

simulated event PostBeginPlay()
{
    TurretBaseClass=class'RPGLinkTurretBase';
    TurretSwivelClass=class'RPGLinkTurretSwivel';
    DefaultWeaponClassName=string(class'Weapon_LinkTurret');

    Super(ASTurret_LinkTurret).PostBeginPlay();
}

defaultproperties
{
    bNonHumanControl=True
    bAutoTurret=True
}
