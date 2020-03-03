class RPGLinkSentinel extends ASTurret
    cacheexempt;

simulated event PostNetBeginPlay()
{
    // Static (non rotating) base
    if ( TurretBaseClass != None )
    {
        // now check if on ceiling or floor. Passed in rotation roll. 0=ceiling.
        if (OriginalRotation.Roll == 0)
            TurretBase = Spawn(TurretBaseClass, Self,, Location-vect(0,0,37), OriginalRotation);
        else
            TurretBase = Spawn(TurretBaseClass, Self,, Location+vect(0,0,37), OriginalRotation);
    }

    // Swivel, rotates left/right (Yaw)
    if ( TurretSwivelClass != None )
    {
        // now check if on ceiling or floor. Passed in rotation roll. 0=ceiling.
        if (OriginalRotation.Roll == 0)
            TurretSwivel = Spawn(TurretSwivelClass, Self,, Location-vect(0,0,37), OriginalRotation);
        else
            TurretSwivel = Spawn(TurretSwivelClass, Self,, Location+vect(0,0,37), OriginalRotation);
    }

    super(ASVehicle).PostNetBeginPlay();
}

function AddDefaultInventory()
{
    // do nothing. Do not want default weapon adding
}

defaultproperties
{
     TurretBaseClass=Class'RPGLinkSentinelBase'
     TurretSwivelClass=Class'RPGLinkSentinelSwivel'
     DefaultWeaponClassName=""
     VehicleNameString="Link Sentinel"
     bCanBeBaseForPawns=False
     bNonHumanControl=True
     Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
     DrawScale=0.250000
     Skins(0)=Shader'EpicParticles.Shaders.InbisThing'
     Skins(1)=Shader'EpicParticles.Shaders.InbisThing'
     AmbientGlow=250
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
