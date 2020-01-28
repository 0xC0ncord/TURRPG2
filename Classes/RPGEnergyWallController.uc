class RPGEnergyWallController extends Controller;

var Controller PlayerSpawner;

function SetPlayerSpawner(Controller PlayerC)
{
    PlayerSpawner = PlayerC;
    if (PlayerSpawner.PlayerReplicationInfo != None && (PlayerSpawner.PlayerReplicationInfo.Team != None || TeamGame(Level.Game) == None))
    {
        if (PlayerReplicationInfo == None)
            PlayerReplicationInfo = Spawn(class'RPGSentinelPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName $ "'s Energy Wall";
        PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
        RPGSentinelPlayerReplicationInfo(PlayerReplicationInfo).bNoTeamBeacon = true;
        if(Pawn != None)
        {
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
            Pawn.bNoTeamBeacon = true;
        }
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
