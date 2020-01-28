class RPGEnergyTurret extends ONSManualGunPawn
    cacheexempt;

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local PlayerController PC;
    local Controller C;

    if ( bDeleteMe || Level.bLevelChange )
        return; // already destroyed, or level is being cleaned up

    if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
    {
        Health = max(Health, 1); //mutator should set this higher
        return;
    }
    Health = Min(0, Health);

    if ( Controller != None )
    {
        C = Controller;
        C.WasKilledBy(Killer);
        Level.Game.Killed(Killer, C, self, damageType);
        if( C.bIsPlayer )
        {
            PC = PlayerController(C);
            if ( PC != None )
                ClientKDriverLeave(PC); // Just to reset HUD etc.
            else
            ClientClearController();
            if ( bRemoteControlled && (Driver != None) && (Driver.Health > 0) )
            {
                C.Unpossess();
                C.Possess(Driver);
                Driver = None;
            }
            else
                C.PawnDied(self);
        }
        else
            C.Destroy();

        if ( Driver != None )
        {
        if (!bRemoteControlled)
        {
                    if (!bDrawDriverInTP && PlaceExitingDriver())
                    {
                        Driver.StopDriving(self);
                        Driver.DrivenVehicle = self;
                    }
                    Driver.TearOffMomentum = Velocity * 0.25;
                    Driver.Died(Controller, class'DamRanOver', Driver.Location);
        }
//        else
//                  KDriverLeave(false);
        }
    }
    else
        Level.Game.Killed(Killer, Controller(Owner), self, damageType);

    if ( Killer != None )
        TriggerEvent(Event, self, Killer.Pawn);
    else
        TriggerEvent(Event, self, None);

    if ( IsHumanControlled() )
        PlayerController(Controller).ForceDeathUpdate();

    Explode(HitLocation);
}

simulated function Explode( vector HitLocation )
{
    if ( Level.NetMode != NM_DedicatedServer )
        Spawn(class'FX_SpaceFighter_Explosion', Self,, HitLocation, Rotation);
    Destroy();
}

simulated event TeamChanged()
{
    Super(ONSWeaponPawn).TeamChanged();
}

defaultproperties
{
     bPowered=True
     RespawnTime=5.000000
     GunClass=Class'Weapon_RPGEnergyTurret'
     AutoTurretControllerClass=None
}
