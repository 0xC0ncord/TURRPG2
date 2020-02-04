class RPGFieldGenerator_Base extends ASVehicle
    cacheexempt;

var FX_FieldBase FieldEffect;

var() class<FX_FieldBase> FieldEffectClass;
var() float ScanRange;

function AddDefaultInventory()
{
    // do nothing. Do not want default weapon adding
}

function Landed(vector hitNormal)
{
    Super.Landed(hitNormal);
    Velocity = vect(0,0,0);

    if(RPGFieldGeneratorController(Controller) != None)
        RPGFieldGeneratorController(Controller).StartFielding();
}

simulated function Destroyed()
{
    Super.Destroyed();
    if(FieldEffect != None)
        FieldEffect.Destroy();
}

function SpawnEffects()
{
    FieldEffect = Spawn(FieldEffectClass, Self,, Location + vect(0,0,128));
}

function ModifyEffect(FX_FieldBase FX);
function DoScan();

defaultproperties
{
    FieldEffectClass=Class'FX_FieldBase'
    ScanRange=192.000000
    DefaultWeaponClassName=""
    VehicleNameString="Field Generator"
    AutoTurretControllerClass=Class'RPGFieldGeneratorController'
    bNonHumanControl=True
    bPathColliding=False
    Physics=PHYS_Falling
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'TURRPG2.Misc.UCBombSpawnMesh'
    DrawScale=5.0
    CollisionHeight=2.0
    CollisionRadius=4.0
    bCollideActors=True
    bBlockActors=False
    bBlockKarma=False
    bCollideWorld=True
    bBlockPlayers=False
    AmbientGlow=10
    HealthMax=1000.000000
    Health=1000
    bNoTeamBeacon=True
}
