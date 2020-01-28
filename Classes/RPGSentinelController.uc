class RPGSentinelController extends ASSentinelController;

var Controller PlayerSpawner;
var RPGPlayerReplicationInfo RPRI;
var float TimeSinceCheck;

var int AttractRange;
var int TargetRange;

var float DamageAdjust;     // set by AbilityLoadedEngineer

function SetPlayerSpawner(Controller PlayerC)
{
    PlayerSpawner = PlayerC;
    if (PlayerSpawner.PlayerReplicationInfo != None && (PlayerSpawner.PlayerReplicationInfo.Team != None || TeamGame(Level.Game) == None))
    {
        if (PlayerReplicationInfo == None)
            PlayerReplicationInfo = spawn(class'RPGSentinelPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s Sentinel";
        PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
//      PlayerReplicationInfo.RemoteRole = ROLE_None;
        if(Pawn!=None)
        {
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
//          Pawn.bNoTeamBeacon = true;
        }
        RPRI=class'RPGPlayerReplicationInfo'.static.GetFor(PlayerSpawner);
    }
}

function bool IsTargetRelevant( Pawn Target )
{
    if ( (Target != None) && (Target.Controller != None)
        && (Target.Health > 0) && (VSize(Target.Location-Pawn.Location) < Pawn.SightRadius*1.25)
        && (((TeamGame(Level.Game) != None) && !SameTeamAs(Target.Controller))
        || ((TeamGame(Level.Game) == None) && (Target.Owner != PlayerSpawner)))
        && (!Target.IsA('LenoreBoss') || Target.GetPropertyText("bIsVulnerableNow")~="True")
        && (!Target.IsA('NaliSage') || Target.GetPropertyText("bIsAppeared")~="True")
        )
        return true;

    return false;
}

function Tick(float DeltaTime)
{
    // need to check for any monsters to target
    local Controller C, NextC;
    local float decision;

    super.Tick(DeltaTime);

    TimeSinceCheck+=DeltaTime;

    if (PlayerSpawner == None || PlayerSpawner.Pawn == None)
        return;

    if(TimeSinceCheck>1.0)
    {
        TimeSinceCheck = 0;

        if(Enemy!=None)
            return;

        C = Level.ControllerList;
        while (C != None)
        {
            // get next controller here because C may be destroyed if it's a nonplayer and C.Pawn is killed
            NextC = C.NextController;

            if (C != None && C.Pawn != None && Pawn != None && C.Pawn != Pawn && C.Pawn != PlayerSpawner.Pawn && C.Pawn.Health > 0
            && VSize(C.Pawn.Location - Pawn.Location) < (TargetRange*DamageAdjust) && !C.Pawn.IsA('ParentBlob') && FastTrace(C.Pawn.Location, Pawn.Location)
               && ((TeamGame(Level.Game) != None && !C.SameTeamAs(PlayerSpawner))   // on a different team
                || (TeamGame(Level.Game) == None && C.Pawn.Owner != PlayerSpawner)))        // or just not me
            {
                SeePlayer(C.Pawn);

                //hack for invasion monsters so they'll fight back
                decision = FRand();
                if ( MonsterController(C) != None && VSize(C.Pawn.Location - Pawn.Location) < AttractRange
                    && ((C.Enemy == None || !C.CanSee(C.Enemy))
                    || (C.Enemy == PlayerSpawner.Pawn && decision < 0.9)
                    || decision < 0.33))
                {
                    MonsterController(C).ChangeEnemy(Pawn, C.CanSee(Pawn));
                }
            }
            C = NextC;
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
     AttractRange=800
     TargetRange=800
     DamageAdjust=1.000000
}