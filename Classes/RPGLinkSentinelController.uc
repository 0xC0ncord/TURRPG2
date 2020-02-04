class RPGLinkSentinelController extends Controller;

var Controller PlayerSpawner;
var RPGPlayerReplicationInfo RPRI;
var FriendlyPawnReplicationInfo FPRI;

var Vehicle HealingVehicle;

var float TimeBetweenShots;
var float LinkRadius;
var float VehicleHealPerShot;
var class<xEmitter> TurretLinkEmitterClass;        // for linking to turrets where we get xp
var class<xEmitter> VehicleLinkEmitterClass;       // for linking to vehicles where we do not get xp

event PostBeginPlay()
{
    Super.PostBeginPlay();
    FPRI = Spawn(class'FriendlyPawnReplicationInfo');
}

function Possess(Pawn aPawn)
{
    Super.Possess(aPawn);
    FPRI.Pawn = aPawn;
}

function SetPlayerSpawner(Controller PlayerC)
{
    PlayerSpawner = PlayerC;
    FPRI.Master = PlayerC.PlayerReplicationInfo;
    if (PlayerSpawner.PlayerReplicationInfo != None && PlayerSpawner.PlayerReplicationInfo.Team != None )
    {
        PlayerReplicationInfo = spawn(class'FriendlyPawnPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s Sentinel";
        PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
        if(Pawn!=None)
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
        RPRI=class'RPGPlayerReplicationInfo'.static.GetFor(PlayerSpawner);
    }
    SetTimer(TimeBetweenShots, true);
}

function Timer()
{
    // lets see if we can link to anything
    Local Pawn LoopP;
    Local Controller C;
    local xEmitter HitEmitter;

    if (Pawn == None || PlayerSpawner == None)
        return;

    HealingVehicle = None;

    foreach DynamicActors(class'Pawn', LoopP)
    {
        // first check if the pawn is anywhere near
        if (LoopP != None &&  LoopP.Health > 0 && Pawn != None && VSize(LoopP.Location - Pawn.Location) < LinkRadius && FastTrace(LoopP.Location, Pawn.Location) && LoopP != Pawn)
        {
            // ok, let's go for it
            C = LoopP.Controller;
            // must be either not controlled, or on same team
            if (C == None || C.SameTeamAs(self) )
            {
                //ok lets see if we can help.
                if (Vehicle(LoopP) != None || RPGEnergyWall(LoopP) != None)
                {
                    // lets see what we can do to help. If a turret, then establish a link. If just a vehicle or sentinel, just heal if it needs it
                    if (!Vehicle(LoopP).bNonHumanControl && (RPGMinigunTurret(LoopP) != None || RPGBallTurret(LoopP) != None || RPGEnergyTurret(LoopP) != None || RPGIonCannon(LoopP) != None))
                    {   // not a link turret :(
                        // estalish an xp link
                        HealingVehicle = Vehicle(LoopP);
                        LoopP.HealDamage(VehicleHealPerShot, self, class'DamTypeLinkShaft');
                        HitEmitter = spawn(TurretLinkEmitterClass,,, Pawn.Location, rotator(LoopP.Location - Pawn.Location));
                        if (HitEmitter != None)
                            HitEmitter.mSpawnVecA = LoopP.Location;
                    }
                    else if (LoopP.Health < LoopP.HealthMax)
                    {
                        // can at least add some health
                        LoopP.GiveHealth(VehicleHealPerShot, LoopP.HealthMax);
                        HitEmitter = spawn(VehicleLinkEmitterClass,,, Pawn.Location, rotator(LoopP.Location - Pawn.Location));
                        if (HitEmitter != None)
                            HitEmitter.mSpawnVecA = LoopP.Location;
                        // and probably ought to get same xp as armor healing powerup on defsent. But sadly that is zero, so nothing.
                    }
                }
            }
        }
    }
}

function Destroyed()
{
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.Destroy();

    Super.Destroyed();
}

defaultproperties
{
     TimeBetweenShots=0.250000
     LinkRadius=700.000000
     VehicleHealPerShot=20.000000
     TurretLinkEmitterClass=Class'FX_RPGLinkSentinelBeam'
     VehicleLinkEmitterClass=Class'FX_Bolt_Bronze'
}
