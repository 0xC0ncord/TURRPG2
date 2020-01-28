class RPGAutoGunSwivel extends ASTurret_Minigun_Swivel;

var rotator startrot;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    startrot = Rotation;
}

simulated function UpdateSwivelRotation( Rotator TurretRotation )
{
    local Rotator SwivelRotation;

    SwivelRotation          = TurretRotation;
    SwivelRotation.Pitch    = 0;
    SwivelRotation.Roll     = startrot.roll;
    SetRotation( SwivelRotation );
}

defaultproperties
{
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.FloorTurretSwivel'
     DrawScale=0.250000
     PrePivot=(Z=150.000000)
     CollisionRadius=50.000000
     CollisionHeight=50.000000
}
