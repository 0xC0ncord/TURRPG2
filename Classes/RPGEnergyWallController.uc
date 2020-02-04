class RPGEnergyWallController extends Controller;

var Controller PlayerSpawner;
var FriendlyPawnReplicationInfo FPRI;

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
    if (PlayerSpawner.PlayerReplicationInfo != None && (PlayerSpawner.PlayerReplicationInfo.Team != None || TeamGame(Level.Game) == None))
    {
        PlayerReplicationInfo = Spawn(class'FriendlyPawnPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName $ "'s Energy Wall";
        PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
        if(Pawn != None)
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
    }
}

simulated function Destroyed()
{
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.Destroy();

    Super.Destroyed();
}

defaultproperties
{
}
