class RPGFieldGeneratorController extends Controller;

var Controller PlayerSpawner;
var RPGPlayerReplicationInfo RPRI;
var bool bAlreadyFielding;

function SetPlayerSpawner(Controller PlayerC)
{
    PlayerSpawner = PlayerC;
    if (PlayerSpawner.PlayerReplicationInfo != None && PlayerSpawner.PlayerReplicationInfo.Team != None )
    {
        if (PlayerReplicationInfo == None)
            PlayerReplicationInfo = Spawn(class'RPGSentinelPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName $ "'s Field";
        PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
        RPGSentinelPlayerReplicationInfo(PlayerReplicationInfo).bNoTeamBeacon = true;
        if(Pawn != None)
        {
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
            Pawn.bNoTeamBeacon = true;
        }
        RPRI=class'RPGPlayerReplicationInfo'.static.GetFor(PlayerSpawner);
    }
}

function StartFielding()
{
    if(bAlreadyFielding)
        return;
    bAlreadyFielding = True;
    RPGFieldGenerator_Base(Pawn).SpawnEffects();
}

function Tick(float dt)
{
    Super.Tick(dt);
    if(!bAlreadyFielding)
        return;
    RPGFieldGenerator_Base(Pawn).DoScan();
}

function bool ProjInstigatorSameTeam(Projectile P) //for projectiles that don't call Super.PostBeginPlay() (i.e. Titan rocks)
{
    if(PlayerSpawner != None && P.Instigator != None && P.Instigator.Controller != None && P.Instigator.Controller.SameTeamAs(PlayerSpawner))
        return true;
}

function Destroyed()
{
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.Destroy();

    Super.Destroyed();
}

defaultproperties
{
}
