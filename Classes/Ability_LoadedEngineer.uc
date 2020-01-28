class Ability_LoadedEngineer extends RPGAbility
    dependson(ArtifactBase_EngineerSummon)
    config(TURRPG2);

var config array<ArtifactBase_EngineerSummon.PawnTypeStruct> BuildingTypes;
var config array<ArtifactBase_EngineerSummon.PawnTypeStruct> SentinelTypes;
var config array<ArtifactBase_EngineerSummon.PawnTypeStruct> TurretTypes;
var config array<ArtifactBase_EngineerSummon.PawnTypeStruct> VehicleTypes;
var config array<ArtifactBase_EngineerSummon.PawnTypeStruct> UtilityTypes;

var config array<ArtifactBase_EngineerSummon.PawnSpawnOffset> ConstructionSpawnOffsets;

var config int PointsPerLevel;

var byte SelectByte;

function ModifyPawn(Pawn Other)
{
    local bool bGotTrans;
    local EngineerLinkGun ELink;
    local int x;
    local Inventory Inv;
    local RPGArtifact A;

    Instigator = Other;

    RPRI.MaxBuildingPoints = AbilityLevel * PointsPerLevel;
    RPRI.MaxSentinelPoints = AbilityLevel * PointsPerLevel;
    RPRI.MaxTurretPoints = AbilityLevel * PointsPerLevel;
    RPRI.MaxVehiclePoints = AbilityLevel * PointsPerLevel;
    RPRI.MaxUtilityPoints = AbilityLevel * PointsPerLevel;
    RPRI.BuildingPoints = RPRI.MaxBuildingPoints;
    RPRI.SentinelPoints = RPRI.MaxSentinelPoints;
    RPRI.TurretPoints = RPRI.MaxTurretPoints;
    RPRI.VehiclePoints = RPRI.MaxVehiclePoints;
    RPRI.UtilityPoints = RPRI.MaxUtilityPoints;

    if(RPRI.Buildings.Length > 0)
        for(x = 0; x < RPRI.Buildings.Length; x++)
            RPRI.BuildingPoints -= RPRI.Buildings[x].Points;
    if(RPRI.Sentinels.Length > 0)
        for(x = 0; x < RPRI.Sentinels.Length; x++)
            RPRI.SentinelPoints -= RPRI.Sentinels[x].Points;
    if(RPRI.Turrets.Length > 0)
        for(x = 0; x < RPRI.Turrets.Length; x++)
            RPRI.TurretPoints -= RPRI.Turrets[x].Points;
    if(RPRI.Vehicles.Length > 0)
        for(x = 0; x < RPRI.Vehicles.Length; x++)
            RPRI.VehiclePoints -= RPRI.Vehicles[x].Points;
    if(RPRI.Utilities.Length > 0)
        for(x = 0; x < RPRI.Utilities.Length; x++)
            RPRI.UtilityPoints -= RPRI.Utilities[x].Points;

    RPRI.ClientCreateStatusIcon(class'StatusIcon_UtilityPoints');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_Utilities');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_VehiclePoints');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_Vehicles');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_TurretPoints');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_Turrets');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_SentinelPoints');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_Sentinels');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_BuildingPoints');
    RPRI.ClientCreateStatusIcon(class'StatusIcon_Buildings');

    // destroy all summoning artifacts as we'll be granting new ones
    // but, remember which one they had selected, if any, so we can reselect it
    A = RPGArtifact(Other.FindInventoryType(class'Artifact_EngineerBuildingSummon'));
    if(A != None)
    {
        if(A == Other.SelectedItem)
            SelectByte = 1;
        A.Destroy();
    }
    A = RPGArtifact(Other.FindInventoryType(class'Artifact_EngineerSentinelSummon'));
    if(A != None)
    {
        if(A == Other.SelectedItem)
            SelectByte = 2;
        A.Destroy();
    }
    A = RPGArtifact(Other.FindInventoryType(class'Artifact_EngineerTurretSummon'));
    if(A != None)
    {
        if(A == Other.SelectedItem)
            SelectByte = 3;
        A.Destroy();
    }
    A = RPGArtifact(Other.FindInventoryType(class'Artifact_EngineerVehicleSummon'));
    if(A != None)
    {
        if(A == Other.SelectedItem)
            SelectByte = 4;
        A.Destroy();
    }
    A = RPGArtifact(Other.FindInventoryType(class'Artifact_EngineerUtilitySummon'));
    if(A != None)
    {
        if(A == Other.SelectedItem)
            SelectByte = 4;
        A.Destroy();
    }

    class'Util'.static.GiveInventory(Other, default.GrantItem[0].InventoryClass);
    class'Util'.static.GiveInventory(Other, default.GrantItem[1].InventoryClass);
    class'Util'.static.GiveInventory(Other, default.GrantItem[2].InventoryClass);
    class'Util'.static.GiveInventory(Other, default.GrantItem[3].InventoryClass);
    class'Util'.static.GiveInventory(Other, default.GrantItem[4].InventoryClass);
    class'Util'.static.GiveInventory(Other, default.GrantItem[5].InventoryClass); //destroy artifact
    class'Util'.static.GiveInventory(Other, default.GrantItem[6].InventoryClass); //destroy artifact

    // lets see if they have a translocator. If not, then perhaps running a gametype that transing isn't a good idea
    // give them a limited translocator that will let them spawn items, but not translocate

    // while we're at it, see if they already have an Engineer Link Gun
    bGotTrans = false;
    for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if(InStr(Caps(Inv.ItemName), "TRANSLOCATOR") > -1 && ClassIsChildOf(Inv.Class, class'Weapon'))
            bGotTrans = true;
        else if(EngineerLinkGun(Inv) != None)
            ELink = EngineerLinkGun(Inv);

        if(ELink != None && bGotTrans)
            break;
    }
    if (!bGotTrans)
        RPRI.QueueWeapon(class'EngineerTransLauncher', None, 0,,, true);

    // Now let's give the EngineerLinkGun
    if(ELink == None || class'WeaponModifier_EngineerLink'.static.GetFor(ELink) == None)
        RPRI.QueueWeapon(class'EngineerLinkGun', class'WeaponModifier_EngineerLink', 0,,, true);
}

function ModifyArtifact(RPGArtifact A)
{
    local Artifact_EngineerBuildingSummon BuildingSummon;
    local Artifact_EngineerSentinelSummon SentinelSummon;
    local Artifact_EngineerTurretSummon TurretSummon;
    local Artifact_EngineerVehicleSummon VehicleSummon;
    local Artifact_EngineerUtilitySummon UtilitySummon;
    local int x;

    if(Artifact_EngineerBuildingSummon(A) != None)
    {
        BuildingSummon = Artifact_EngineerBuildingSummon(A);
        if(SelectByte == 1)
            A.Instigator.SelectedItem = A;
    }
    else if(Artifact_EngineerSentinelSummon(A) != None)
    {
        SentinelSummon = Artifact_EngineerSentinelSummon(A);
        if(SelectByte == 2)
            A.Instigator.SelectedItem = A;
    }
    else if(Artifact_EngineerTurretSummon(A) != None)
    {
        TurretSummon = Artifact_EngineerTurretSummon(A);
        if(SelectByte == 3)
            A.Instigator.SelectedItem = A;
    }
    else if(Artifact_EngineerVehicleSummon(A) != None)
    {
        VehicleSummon = Artifact_EngineerVehicleSummon(A);
        if(SelectByte == 4)
            A.Instigator.SelectedItem = A;
    }
    else if(Artifact_EngineerUtilitySummon(A) != None)
    {
        UtilitySummon = Artifact_EngineerUtilitySummon(A);
        if(SelectByte == 4)
            A.Instigator.SelectedItem = A;
    }
    SelectByte = 0;

    if(BuildingSummon != None)
    {
        BuildingSummon.ConstructionTypes.Length = 0;
        for(x = 0; x < BuildingTypes.Length; x++)
        {
            if(AbilityLevel >= BuildingTypes[x].Level && BuildingTypes[x].PawnClass != None)
            {
                BuildingSummon.ConstructionTypes[x] = BuildingTypes[x];
            }
        }
        BuildingSummon.ServerSendConstructionTypes();
        BuildingSummon.ConstructionSpawnOffsets = ConstructionSpawnOffsets;
    }
    else if(SentinelSummon != None)
    {
        SentinelSummon.ConstructionTypes.Length = 0;
        for(x = 0; x < SentinelTypes.Length; x++)
        {
            if(AbilityLevel >= SentinelTypes[x].Level && SentinelTypes[x].PawnClass != None)
            {
                SentinelSummon.ConstructionTypes[x] = SentinelTypes[x];
            }
        }
        SentinelSummon.ServerSendConstructionTypes();
        SentinelSummon.ConstructionSpawnOffsets = ConstructionSpawnOffsets;
    }
    else if(TurretSummon != None)
    {
        TurretSummon.ConstructionTypes.Length = 0;
        for(x = 0; x < TurretTypes.Length; x++)
        {
            if(AbilityLevel >= TurretTypes[x].Level && TurretTypes[x].PawnClass != None)
            {
                TurretSummon.ConstructionTypes[x] = TurretTypes[x];
            }
        }
        TurretSummon.ServerSendConstructionTypes();
        TurretSummon.ConstructionSpawnOffsets = ConstructionSpawnOffsets;
    }
    else if(VehicleSummon != None)
    {
        VehicleSummon.ConstructionTypes.Length = 0;
        for(x = 0; x < VehicleTypes.Length; x++)
        {
            if(AbilityLevel >= VehicleTypes[x].Level && VehicleTypes[x].PawnClass != None)
            {
                VehicleSummon.ConstructionTypes[x] = VehicleTypes[x];
            }
        }
        VehicleSummon.ServerSendConstructionTypes();
        VehicleSummon.ConstructionSpawnOffsets = ConstructionSpawnOffsets;
    }
    else if(UtilitySummon != None)
    {
        UtilitySummon.ConstructionTypes.Length = 0;
        for(x = 0; x < UtilityTypes.Length; x++)
        {
            if(AbilityLevel >= UtilityTypes[x].Level && UtilityTypes[x].PawnClass != None)
            {
                UtilitySummon.ConstructionTypes[x] = UtilityTypes[x];
            }
        }
        UtilitySummon.ServerSendConstructionTypes();
        UtilitySummon.ConstructionSpawnOffsets = ConstructionSpawnOffsets;
    }
}

defaultproperties
{
    ConstructionSpawnOffsets(0)=(PawnClass=Class'RPGBlock',SpawnOffset=(X=0,Y=0,Z=1))
    ConstructionSpawnOffsets(1)=(PawnClass=Class'RPGSmallBlock',SpawnOffset=(X=0,Y=0,Z=1))
    ConstructionSpawnOffsets(2)=(PawnClass=Class'RPGExplosive',SpawnOffset=(X=0,Y=0,Z=1))
    ConstructionSpawnOffsets(3)=(PawnClass=Class'RPGExplosiveLarge',SpawnOffset=(X=0,Y=0,Z=1))
    ConstructionSpawnOffsets(4)=(PawnClass=Class'RPGAutoGun',SpawnOffset=(X=0,Y=0,Z=36),CeilingSpawnOffset=(X=0,Y=0,Z=-36))
    ConstructionSpawnOffsets(5)=(PawnClass=Class'RPGDefenseSentinel',SpawnOffset=(X=0,Y=0,Z=30),CeilingSpawnOffset=(X=0,Y=0,Z=-48))
    ConstructionSpawnOffsets(6)=(PawnClass=Class'RPGLightningSentinel',SpawnOffset=(X=0,Y=0,Z=30),CeilingSpawnOffset=(X=0,Y=0,Z=-48))
    ConstructionSpawnOffsets(7)=(PawnClass=Class'RPGLinkSentinel',SpawnOffset=(X=0,Y=0,Z=67),CeilingSpawnOffset=(X=0,Y=0,Z=2))
    ConstructionSpawnOffsets(8)=(PawnClass=Class'RPGSentinel',SpawnOffset=(X=0,Y=0,Z=73),CeilingSpawnOffset=(X=0,Y=0,Z=-60))
    ConstructionSpawnOffsets(9)=(PawnClass=Class'RPGMinigunTurret',SpawnOffset=(X=0,Y=0,Z=36))
    ConstructionSpawnOffsets(10)=(PawnClass=Class'RPGMinigunTurret_Auto',SpawnOffset=(X=0,Y=0,Z=36))
    ConstructionSpawnOffsets(11)=(PawnClass=Class'RPGEnergyTurret',SpawnOffset=(X=0,Y=0,Z=74))
    ConstructionSpawnOffsets(12)=(PawnClass=Class'RPGBallTurret',SpawnOffset=(X=0,Y=0,Z=88))
    ConstructionSpawnOffsets(13)=(PawnClass=Class'RPGBallTurret_Auto',SpawnOffset=(X=0,Y=0,Z=88))
    ConstructionSpawnOffsets(14)=(PawnClass=Class'RPGLinkTurret',SpawnOffset=(X=0,Y=0,Z=76))
    ConstructionSpawnOffsets(15)=(PawnClass=Class'RPGLinkTurret_Auto',SpawnOffset=(X=0,Y=0,Z=76))
    ConstructionSpawnOffsets(16)=(PawnClass=Class'RPGIonCannon',SpawnOffset=(X=0,Y=0,Z=86))
    RequiredLevels(0)=3
    RequiredLevels(1)=6
    RequiredLevels(2)=9
    RequiredLevels(3)=12
    RequiredLevels(4)=15
    RequiredLevels(5)=18
    RequiredLevels(6)=21
    RequiredLevels(7)=24
    RequiredLevels(8)=27
    RequiredLevels(9)=30
    RequiredLevels(10)=33
    RequiredLevels(11)=36
    RequiredLevels(12)=39
    RequiredLevels(13)=42
    RequiredLevels(14)=45
    GrantItem(0)=(Level=1,InventoryClass=Class'Artifact_EngineerBuildingSummon')
    GrantItem(1)=(Level=1,InventoryClass=Class'Artifact_EngineerSentinelSummon')
    GrantItem(2)=(Level=1,InventoryClass=Class'Artifact_EngineerTurretSummon')
    GrantItem(3)=(Level=1,InventoryClass=Class'Artifact_EngineerVehicleSummon')
    GrantItem(4)=(Level=1,InventoryClass=Class'Artifact_EngineerUtilitySummon')
    GrantItem(5)=(Level=1,InventoryClass=Class'Artifact_EngineerDestroySummon')
    GrantItem(6)=(Level=1,InventoryClass=Class'Artifact_EngineerDestroyTargetSummon')
    AbilityName="Loaded Engineer"
    Description="Learn sentinels, turrets, vehicle and buildings to summon. At each level, you can summon better items."
    StartingCost=3
    CostAddPerLevel=1
    MaxLevel=15
    PointsPerLevel=1
    Category=Class'TURRPG2.AbilityCategory_Engineer'
}
