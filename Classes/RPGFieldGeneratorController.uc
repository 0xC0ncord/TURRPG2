class RPGFieldGeneratorController extends Controller;

var Controller PlayerSpawner;
var RPGPlayerReplicationInfo RPRI;
var FriendlyPawnReplicationInfo FPRI;

var bool bAlreadyFielding;

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
        PlayerReplicationInfo = Spawn(class'FriendlyPawnPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName $ "'s Field";
        PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
        if(Pawn != None)
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
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
