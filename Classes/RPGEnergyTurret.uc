class RPGEnergyTurret extends ONSManualGunPawn
    cacheexempt;

// Zooming
var bool bZooming;
var float MinPlayerFOV, OldFOV, ZoomSpeed;

// Copied from ASTurret
simulated function RawInput(float DeltaTime,
                            float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
                            float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
    local playerController  PC;
    local float             NewFOV;

    if ( PlayerController(Controller) != None )
    {
        PC = PlayerController(Controller);
        if ( aForward!=0 )
        {
            bZooming = true;

            if ( aForward>0 )
            {
                if ( PC.FOVAngle > MinPlayerFOV )
                    NewFOV = PC.FOVAngle - ((PC.DefaultFOV - MinPlayerFOV)*DeltaTime*ZoomSpeed);
                else
                    NewFOV = MinPlayerFOV;
            }
            else
            {
                if ( PC.FOVAngle < PC.DefaultFOV )
                    NewFOV = PC.FOVAngle + ((PC.DefaultFOV - MinPlayerFOV)*DeltaTime*ZoomSpeed);
                else
                    NewFOV = PC.DefaultFOV;
            }
        }
        else
            bZooming = false;

        if ( bZooming )
            PC.SetFOV( FClamp(NewFOV, MinPlayerFOV, PC.DefaultFOV)  );

        if ( OldFOV == 0 )
            OldFOV = PC.FOVAngle;

        if ( OldFOV != PC.FOVAngle )
            PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomIn', SLOT_Misc,,,,,false);

        OldFOV = PC.FOVAngle;
    }

    super.RawInput(DeltaTime, aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY, aForward, aTurn, aStrafe, aUp, aLookUp);
}

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
     MinPlayerFOV=20.000000
     ZoomSpeed=1.500000
     bPowered=True
     RespawnTime=5.000000
     GunClass=Class'Weapon_RPGEnergyTurret'
     AutoTurretControllerClass=None
}
