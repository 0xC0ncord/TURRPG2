class FX_ConstructionSpawn extends Emitter;

var Pawn PawnOwner;

replication
{
    reliable if(Role == Role_Authority && bNetInitial)
        PawnOwner;
}

function PostBeginPlay()
{
    PawnOwner = Pawn(Owner);
    Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
    local int i;

    if(PawnOwner != None)
    {
        PawnOwner.Spawn(class'FX_ConstructionSpawnLeaveBody', PawnOwner,, PawnOwner.Location, PawnOwner.Rotation);
        if(ASTurret(PawnOwner)!=None)
        {
            if(ASTurret(PawnOwner).TurretBase != None)
                PawnOwner.Spawn(class'FX_ConstructionSpawnLeaveBody', ASTurret(PawnOwner).TurretBase,, ASTurret(PawnOwner).TurretBase.Location, ASTurret(PawnOwner).TurretBase.Rotation);
            if(ASTurret(PawnOwner).TurretSwivel != None)
                PawnOwner.Spawn(class'FX_ConstructionSpawnLeaveBody', ASTurret(PawnOwner).TurretSwivel,, ASTurret(PawnOwner).TurretSwivel.Location, ASTurret(PawnOwner).TurretSwivel.Rotation);
            if(RPGEnergyWall(PawnOwner) != None)
            {
                if(RPGEnergyWall(PawnOwner).Post1 != None)
                    PawnOwner.Spawn(class'FX_ConstructionSpawnLeaveBody', RPGEnergyWall(PawnOwner).Post1,, RPGEnergyWall(PawnOwner).Post1.Location, RPGEnergyWall(PawnOwner).Post1.Rotation);
                if(RPGEnergyWall(PawnOwner).Post2 != None)
                    PawnOwner.Spawn(class'FX_ConstructionSpawnLeaveBody', RPGEnergyWall(PawnOwner).Post2,, RPGEnergyWall(PawnOwner).Post2.Location, RPGEnergyWall(PawnOwner).Post2.Rotation);
            }
        }
        else if(ONSVehicle(PawnOwner) != None)
        {
            for(i = 0; i < ONSVehicle(PawnOwner).Weapons.Length; i++)
            {
                if(ONSVehicle(PawnOwner).Weapons[i] != None)
                    PawnOwner.Spawn(class'FX_ConstructionSpawnLeaveBody', ONSVehicle(PawnOwner).Weapons[i],, ONSVehicle(PawnOwner).Weapons[i].Location, PawnOwner.Rotation);
            }
            for(i = 0; i < ONSVehicle(PawnOwner).WeaponPawns.Length; i++)
            {
                if(ONSVehicle(PawnOwner).WeaponPawns[i]!=None)
                    PawnOwner.Spawn(class'FX_ConstructionSpawnLeaveBody', ONSVehicle(PawnOwner).WeaponPawns[i],, ONSVehicle(PawnOwner).WeaponPawns[i].Location, PawnOwner.Rotation);
            }
        }
    }
}

defaultproperties
{
    LifeSpan=5.000000
    SoundVolume=255
    bNoDelete=False
    RemoteRole=Role_SimulatedProxy
    bNotOnDedServer=False
    bNetTemporary=True
}
