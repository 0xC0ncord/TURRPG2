class RPGLightningSentinelController extends Controller;

var Controller PlayerSpawner;
var FriendlyPawnReplicationInfo FPRI;

var class<xEmitter> HitEmitterClass;

var float MaxHealthMultiplier;
var float MinHealthMultiplier;
var int MaxDamagePerHit;
var int MinDamagePerHit;
var float TargetRadius;

var float DamageAdjust;     // set by AbilityLoadedEngineer

event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(1.0, true);
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
    }
}

function Timer()
{
    // lets target some enemies
    local Controller C, NextC;
    local int DamageDealt;
    local xEmitter HitEmitter;
    local float damageScale, dist;
    local vector dir;
    local float decision;

    if (PlayerSpawner == None || PlayerSpawner.Pawn == None)
        return;

    C = Level.ControllerList;
    while (C != None)
    {
        // get next controller here because C may be destroyed if it's a nonplayer and C.Pawn is killed
        NextC = C.NextController;

        if (C != None && C.Pawn != None && Pawn != None && C.Pawn != Pawn && C.Pawn != PlayerSpawner.Pawn && C.Pawn.Health > 0
          && VSize(C.Pawn.Location - Pawn.Location) < TargetRadius && !C.Pawn.IsA('ParentBlob') && FastTrace(C.Pawn.Location, Pawn.Location)
          && ((TeamGame(Level.Game) != None && !C.SameTeamAs(PlayerSpawner))    // on a different team
            || (TeamGame(Level.Game) == None && C.Pawn.Owner != PlayerSpawner)) // or just not me
            && (!C.Pawn.IsA('LenoreBoss') || C.Pawn.GetPropertyText("bIsVulnerableNow")~="True")
            && (!C.Pawn.IsA('NaliSage') || C.Pawn.GetPropertyText("bIsAppeared")~="True")
            )
        {
            // scale damage done according to distnace from sentinel
            dir = C.Pawn.Location - Pawn.Location;
            dist = FMax(1,VSize(dir));
            damageScale = 1 - FMax(0,dist/TargetRadius);

            DamageDealt = C.Pawn.HealthMax * DamageAdjust * ((damageScale * (MaxHealthMultiplier-MinHealthMultiplier)) + MinHealthMultiplier);
            DamageDealt = max(MinDamagePerHit * DamageAdjust, DamageDealt);
            DamageDealt = min(MaxDamagePerHit * DamageAdjust, DamageDealt);
            C.Pawn.TakeDamage(DamageDealt, Pawn, C.Pawn.Location, vect(0,0,0), class'DamTypeLightningSentinel');

            if (C != None && C.Pawn != None && Pawn != None)
            {
                HitEmitter = spawn(HitEmitterClass,,, Pawn.Location, rotator(C.Pawn.Location - Pawn.Location));
                if (HitEmitter != None)
                {
                    HitEmitter.mSpawnVecA = C.Pawn.Location;
                    HitEmitter.LifeSpan = 0.500000;
                }
            }

            //hack for invasion monsters so they'll fight back
            /*
            if (C != None && C.Pawn != None && MonsterController(C) != None && FriendlyMonsterController(C) == None && Pawn != None
                  && C.Enemy != Pawn && FastTrace(Pawn.Location,C.Pawn.Location))
            {
                if ((C.Enemy == None || !C.CanSee(C.Enemy)) || FRand() < 0.15 )
                    MonsterController(C).ChangeEnemy(Pawn, C.CanSee(Pawn));
            }
            */
            decision = FRand();
            if(C != None && C.Pawn != None && MonsterController(C) != None && FriendlyMonsterController(C) == None && Pawn != None
                && FastTrace(Pawn.Location, C.Pawn.Location)
                && ((C.Enemy == None || !C.CanSee(C.Enemy))
                || (C.Enemy == PlayerSpawner.Pawn && decision < 0.66)
                || decision < 0.15))
            {
                MonsterController(C).ChangeEnemy(Pawn, C.CanSee(Pawn));
            }
        }
        C = NextC;
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
     HitEmitterClass=Class'XEffects.LightningBolt'
     MaxHealthMultiplier=0.100000
     MinHealthMultiplier=0.020000
     MaxDamagePerHit=30
     MinDamagePerHit=3
     TargetRadius=1200.000000
     DamageAdjust=1.000000
}
