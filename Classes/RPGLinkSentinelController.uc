class RPGLinkSentinelController extends Controller
    config(TURRPG2);

var Controller PlayerSpawner;
var RPGPlayerReplicationInfo RPRI;
var FriendlyPawnReplicationInfo FPRI;

var array<Vehicle> LinkedVehicles;

var float TimeBetweenShots;
var float LinkRadius;
var float VehicleHealPerShot;
var class<xEmitter> TurretLinkEmitterClass;        // for linking to turrets where we get xp
var class<xEmitter> VehicleLinkEmitterClass;       // for linking to vehicles where we do not get xp

var() config array<class<Vehicle> > LinkableVehicles;

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
    Local Pawn LoopP, HealTarget;
    local array<Vehicle> HealedVehicles;
    Local Controller C;
    local xEmitter HitEmitter;

    if (Pawn == None || PlayerSpawner == None)
        return;

    LinkedVehicles.Length = 0;

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
                if (Vehicle(LoopP) != None)
                {
                    // lets see what we can do to help. If a turret, then establish a link. If just a vehicle or sentinel, just heal if it needs it
                    if (!Vehicle(LoopP).bNonHumanControl && class'Util'.static.InArray(LoopP.Class, LinkableVehicles) != -1)
                    {   // not a link turret :(
                        // estalish an xp link
                        LinkedVehicles[LinkedVehicles.Length] = Vehicle(LoopP);
                        LoopP.HealDamage(VehicleHealPerShot, self, class'DamTypeLinkShaft');
                        HitEmitter = spawn(TurretLinkEmitterClass,,, Pawn.Location, rotator(LoopP.Location - Pawn.Location));
                        if (HitEmitter != None)
                            HitEmitter.mSpawnVecA = LoopP.Location;

                        HealedVehicles[HealedVehicles.Length] = Vehicle(LoopP);
                    }
                    else
                    {
                        // if this is a weapon pawn, heal the base vehicle instead
                        if(ONSWeaponPawn(LoopP) != None && !ONSWeaponPawn(LoopP).bHasOwnHealth && ONSWeaponPawn(LoopP).VehicleBase != None)
                        {
                            HealTarget = class'Util'.static.GetRootVehicle(Vehicle(LoopP));
                            if(class'Util'.static.InArray(HealTarget, HealedVehicles) != -1)
                                continue;
                        }
                        else
                            HealTarget = LoopP;

                        if (HealTarget.Health < HealTarget.HealthMax)
                        {
                            // can at least add some health
                            HealedVehicles[HealedVehicles.Length] = Vehicle(HealTarget);
                            HealTarget.GiveHealth(VehicleHealPerShot, HealTarget.HealthMax);
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
}

function Destroyed()
{
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.Destroy();

    Super.Destroyed();
}

defaultproperties
{
    LinkableVehicles(0)=Class'RPGMinigunTurret'
    LinkableVehicles(1)=Class'RPGBallTurret'
    LinkableVehicles(2)=Class'RPGEnergyTurret'
    LinkableVehicles(3)=Class'RPGIonCannon'
    TimeBetweenShots=0.250000
    LinkRadius=700.000000
    VehicleHealPerShot=20.000000
    TurretLinkEmitterClass=Class'FX_RPGLinkSentinelBeam'
    VehicleLinkEmitterClass=Class'FX_Bolt_Bronze'
}
