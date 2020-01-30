class Beacon_ConjurerSummon extends BeaconBase_Summon;

var Emitter FX;
var float MaxDistance;

var vector HitNormal;
var vector SpawnLoc;
var vector SummonSpawnLoc;

replication
{
    reliable if(Role == Role_Authority && bNetInitial)
        SpawnLoc;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    if(Role == ROLE_Authority)
        SpawnLoc = Location;
}

simulated event PostNetBeginPlay()
{
    FX = Spawn(class'FX_ConjurerSummonBeacon', self);
}

simulated event HitWall(vector HitNormal, Actor Wall)
{
    if(Role == Role_Authority)
    {
        if(!SetLocation(Location + (HitNormal * SummonClass.default.CollisionRadius)))
        {
            Destroy();
            return;
        }
        GotoState('Spawning');
    }
    if(FX != None)
        FX.Kill();
}

simulated event Tick(float dt)
{
    Super(RPGArtifactBeacon).Tick(dt);

    if(VSize(SpawnLoc - Location) >= MaxDistance)
    {
        if(Role == ROLE_Authority && !IsInState('Spawning'))
            GotoState('Spawning');
        if(FX != None)
            FX.Kill();
    }
}

simulated function Destroyed()
{
    Super.Destroyed();
    if(FX != None)
        FX.Kill();
}

final function vector FindSpawnLocation()
{
    if(CheckSpace(Location))
        return Location;
    return vect(0,0,0);
}

final function bool CheckSpace(vector TestVect)
{
    if(!FastTrace(TestVect, Location + vect(1, 0, 0) * SummonClass.default.CollisionRadius) ||
        !FastTrace(TestVect, Location + vect(-1, 0, 0) * SummonClass.default.CollisionRadius) ||
        !FastTrace(TestVect, Location + vect(0, 1, 0) * SummonClass.default.CollisionRadius) ||
        !FastTrace(TestVect, Location + vect(0, -1, 0) * SummonClass.default.CollisionRadius) ||
        !FastTrace(TestVect, Location + vect(0, 0, 1) * SummonClass.default.CollisionHeight) ||
        !FastTrace(TestVect, Location + vect(0, 0, -1) * SummonClass.default.CollisionHeight))
        return false;
    return true;
}

state Spawning
{
Begin:
    SetCollision(false, false, false);
    SetPhysics(PHYS_None);
    SummonSpawnLoc = FindSpawnLocation();
    if(SummonSpawnLoc != vect(0,0,0))
    {
        bLanded = True;
        SetLocation(SummonSpawnLoc);
        Spawn(class'FX_FriendlyMonsterSpawn', self,, SummonSpawnLoc).PawnClass = class<Pawn>(SummonClass);
        Sleep(2.0);
        Artifact.BeaconLanded(Self);
    }
    else
        Destroy();
}

defaultproperties
{
    MaxDistance=500.000000
    Speed=5000.000000
    MaxSpeed=5000.000000
    DrawType=DT_None
    Physics=PHYS_Projectile
    bBlockNonZeroExtentTraces=False
    bBlockZeroExtentTraces=False
    bProjTarget=False
    bBlockActors=False
    bCollideActors=False
}
