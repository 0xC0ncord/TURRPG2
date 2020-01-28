class RPGEnergyWallPost extends Actor;

var RPGEnergyWall Wall;

simulated function PostNetBeginPlay()
{
    Super.PostBeginPlay();
    Self.SetDrawScale3D(vect(0.8, 0.8, 1.3));
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    // Defer damage to Wall...
    if(Role == Role_Authority && InstigatedBy != Owner)
    {
        if (Wall != None && Wall.DamageFraction > 0)
            Wall.TakeDamage(Damage/wall.DamageFraction, instigatedBy, hitlocation, momentum, damageType); // since direct hit on post, need to do whole of damage to wall
        else
            Wall.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
    }
}

defaultproperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleBomb'
    bReplicateMovement=False
    bUpdateSimulatedPosition=True
    NetUpdateFrequency=4.000000
    DrawScale=0.220000
    AmbientGlow=10
    bMovable=False
    CollisionRadius=8.000000
    CollisionHeight=60.000000
    bCollideActors=True
    bCollideWorld=True
    bBlockActors=True
    bBlockPlayers=True
    bProjTarget=True
    bUseCylinderCollision=True
    Mass=1000.000000
}
