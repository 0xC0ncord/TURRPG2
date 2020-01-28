class RPGCeilingLightningSentinel extends ASTurret
    cacheexempt;

function AddDefaultInventory()
{
    // do nothing. Do not want default weapon adding
}

defaultproperties
{
    DefaultWeaponClassName=""
    VehicleNameString="Ceiling Lightning Sentinel"
    bCanBeBaseForPawns=False
    Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'
    DrawScale=0.300000
    Skins(0)=Combiner'CeilingLightning_C'
    Skins(1)=Combiner'CeilingLightning_C'
    AmbientGlow=120
    CollisionRadius=45.000000
    CollisionHeight=60.000000
}
