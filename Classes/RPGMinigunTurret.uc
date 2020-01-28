class RPGMinigunTurret extends ASTurret_Minigun
    cacheexempt;

function bool HasUDamage()
{
    return (Driver != None && Driver.HasUDamage());
}

// TakeDamage taken from ASVehicle and modified to force eject rather than crash
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                        Vector momentum, class<DamageType> damageType)
{
    local int           actualDamage;
    local bool          bAlreadyDead;
    local Controller    Killer;

    if ( Role < ROLE_Authority )
    {
        log(self$" client damage type "$damageType$" by "$instigatedBy);
        return;
    }

    if ( Level.Game == None )
        return;

    // Spawn Protection: Cannot be destroyed by a player until possessed
    if ( bSpawnProtected && instigatedBy != None && instigatedBy != Self )
        return;

    // Prevent multiple damage the same tick (for splash damage deferred by turret bases for example)
    if ( Level.TimeSeconds == DamLastDamageTime && instigatedBy == DamLastInstigator )
        return;

    DamLastInstigator = instigatedBy;
    DamLastDamageTime = Level.TimeSeconds;

    if ( damagetype == None )
        DamageType = class'DamageType';

    Damage      *= DamageType.default.VehicleDamageScaling;
    momentum    *= DamageType.default.VehicleMomentumScaling * MomentumMult;
    bAlreadyDead = (Health <= 0);
    NetUpdateTime = Level.TimeSeconds - 1; // force quick net update

    if ( Weapon != None )
        Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
    if ( (InstigatedBy != None) && InstigatedBy.HasUDamage() )
        Damage *= 2;

    actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

    if ( DamageType.default.bArmorStops && (actualDamage > 0) )
        actualDamage = ShieldAbsorb( actualDamage );

    if ( bShowDamageOverlay && DamageType.default.DamageOverlayMaterial != None && actualDamage > 0 )
        SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true );

    Health -= actualDamage;

    if ( HitLocation == vect(0,0,0) )
        HitLocation = Location;
    if ( bAlreadyDead )
        return;

    PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
    if ( Health <= 0 )
    {
//      if ( Driver != None )
//          KDriverLeave( false );

        // pawn died
        if ( instigatedBy != None )
            Killer = instigatedBy.GetKillerController();
        else if ( (DamageType != None) && DamageType.default.bDelayedDamage )
            Killer = DelayedDamageInstigatorController;

        Health = 0;

        TearOffMomentum = momentum;

        Died(Killer, damageType, HitLocation);
    }
    else
    {
        if ( Controller != None )
            Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
    }

    MakeNoise(1.0);
}

simulated function Destroyed_HandleDriver()
{
    Driver.LastRenderTime = LastRenderTime;
    if ( Role != ROLE_Authority )
        if ( Driver.DrivenVehicle == self )
            Driver.StopDriving(self);
}

defaultproperties
{
     DriverDamageMult=0.000000
}
