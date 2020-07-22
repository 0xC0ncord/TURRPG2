//=============================================================================
// RPGEnergyTurret.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGEnergyTurret extends ONSManualGunPawn
    cacheexempt;

var Controller DestroyPrevController;

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

    NetUpdateFrequency = default.NetUpdateFrequency;
    PlayDying(DamageType, HitLocation);
    if(Level.Game.bGameEnded)
        return;
    if(!bPhysicsAnimUpdate && !IsLocallyControlled())
        ClientDying(DamageType, HitLocation);
}

// copied from ASVehicle
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    Explode( Location, vect(0,0,1) );

    if ( Level.Game != None )
        Level.Game.DiscardInventory( Self );

    // Make sure player controller is actually possessing the vehicle.. (since we forced it in ClientKDriverEnter)
    if ( PlayerController(Controller) != None && PlayerController(Controller).Pawn != Self )
        Controller = None;

    if ( PlayerController(Controller) != None )
    {
        if ( bDrawDriverInTP && Driver != None )    // view driver dying
            PlayerController(Controller).SetViewTarget( Driver );
        else
            PlayerController(Controller).SetViewTarget( Self );
    }

    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    GotoState('Dying');
}

// explode
state Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

    //simulated function PlayDying(class<DamageType> DamageType, vector HitLoc) {}
    event ChangeAnimation() {}
    event StopPlayFiring() {}
    function PlayFiring(float Rate, name FiringMode) {}
    function PlayWeaponSwitch(Weapon NewWeapon) {}
    function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
    simulated function PlayNextAnimation() {}
    event FellOutOfWorld(eKillZType KillType) { }
    function Landed(vector HitNormal) { }
    function ReduceCylinder() { }
    function LandThump() {  }
    event AnimEnd(int Channel) {    }
    function LieStill() {}
    singular function BaseChange() {    }
    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {}
    function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                            Vector momentum, class<DamageType> damageType) {}

    function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange)  { }
    function VehicleSwitchView(bool bUpdating) {}
    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);
    function DriverDied();

    simulated function Timer()
    {
        if ( !bDeleteMe )
            Destroy();
    }

    function BeginState()
    {
        local PlayerController  PC, LocalPlayer;

        LocalPlayer     = Level.GetLocalPlayerController();
        AmbientSound    = None;
        Velocity        = vect(0,0,0);
        Acceleration    = Velocity;
        bHidden         = true;
        if(Gun != None)
            Gun.bHidden = true;

        SetPhysics( PHYS_None );
        SetCollision(false, false, false);

        // Make sure player controller is actually possessing the vehicle.. (since we forced it in ClientKDriverEnter)
        if ( PlayerController(Controller) != None && PlayerController(Controller).Pawn != Self )
            Controller = None;

        // Clear previous controller if not currently viewing this vehicle.
        if ( PlayerController(DestroyPrevController) != None && PlayerController(DestroyPrevController).ViewTarget != Self )
            DestroyPrevController = None;

        if ( PlayerController(Controller) != None )
            PC = PlayerController(Controller);
        else if ( PlayerController(DestroyPrevController) != None )
            PC = PlayerController(DestroyPrevController);

        // Force behind view
        if ( PC != None && !PC.bBehindView )
            PC.bBehindView = true;

        if ( Driver != None && bDrawDriverInTP )
            Destroyed_HandleDriver();

        // If server, wait a second for replication
        if ( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )
            SetTimer(1.f, false);
        else if ( (Driver == None || !bDrawDriverInTP) &&
            ( (PC != None ) || (LocalPlayer != None && LocalPlayer.ViewTarget == Self) ) )
        {
            // If owned by player, or spectated wait a bit so explosion can be viewed
            // (if there viewtarget is not already set on driver's dead body)
            if ( Controller != None )
            {
                DestroyPrevController = Controller;
                Controller.SetRotation( Rotation );
                Controller.PawnDied( Self );
                DestroyPrevController.SetRotation( Rotation );
            }
            else if ( DestroyPrevController != None )
            {
                DestroyPrevController.SetRotation( Rotation );
                DestroyPrevController.SetLocation( Location );
            }

            SetTimer(5.f, false);
        }
        else
        {
            // if not owned and not spectated then destroy right away
            if ( Controller != None )
                Controller.PawnDied( Self );

            Destroy();
        }

    }
}

// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal )
{
    if ( Level.NetMode != NM_DedicatedServer )
        Spawn(class'FX_SpaceFighter_Explosion', Self,, HitLocation, Rotation);
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
