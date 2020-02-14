class RPGFieldGenerator extends ASVehicle
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

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    local int actualDamage;
    local Controller Killer;

    if(DamageType == None)
    {
        if(InstigatedBy != None)
            Warn("No DamageType for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
        DamageType = class'DamageType';
    }

    if(Role < ROLE_Authority)
        return;

    if(Health <= 0)
        return;

    if((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
        instigatedBy = DelayedDamageInstigatorController.Pawn;

    if((InstigatedBy != None) && InstigatedBy.HasUDamage())
        Damage *= 2;

    momentum = vect(0, 0, 0); // fields do not move

    actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, momentum, DamageType);
    momentum = vect(0, 0, 0); // reset in case changed

    Health -= actualDamage;
    if(HitLocation == vect(0, 0, 0))
        HitLocation = Location;

    PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, momentum);
    if(Health <= 0)
    {
        // pawn died
        if(DamageType.default.bCausedByWorld && (instigatedBy == None || instigatedBy == self) && LastHitBy != None)
            Killer = LastHitBy;
        else if(instigatedBy != None)
            Killer = instigatedBy.GetKillerController();
        if(Killer == None && DamageType.Default.bDelayedDamage)
            Killer = DelayedDamageInstigatorController;
        Died(Killer, damageType, HitLocation);
    }
    else
    {
        if(Controller != None)
            Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, momentum);
        if(instigatedBy != None && instigatedBy != self)
            LastHitBy = instigatedBy.Controller;
    }
    MakeNoise(1.0);

    if(Health <= 0)
        Destroy();
    else
        Velocity = vect(0, 0, 0);
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
    PrePivot=(Z=0.3)
    CollisionHeight=2.0
    CollisionRadius=4.0
    Mass=10000.000000
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
