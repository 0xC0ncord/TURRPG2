class RPGLightningSentinel extends ASTurret
    cacheexempt;

function AddDefaultInventory()
{
    // do nothing. Do not want default weapon adding
}

defaultproperties
{
    TurretBaseClass=Class'RPGLightningSentinelBase'
    DefaultWeaponClassName=""
    VehicleNameString="Lightning Sentinel"
    bCanBeBaseForPawns=False
    bNonHumanControl=True
    Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
    DrawScale=0.500000
    AmbientGlow=120
    CollisionRadius=0.000000
    CollisionHeight=0.000000
}
