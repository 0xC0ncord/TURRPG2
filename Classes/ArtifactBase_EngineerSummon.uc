class ArtifactBase_EngineerSummon extends ArtifactBase_Construct
    dependson(Util);

var string FriendlyName;
var int Points;
var int StartHealth;
var int NormalHealth;

var string ConstructionType;

var class<Actor> SpawnActorClassCeiling;
var class<Controller> SpawnControllerClass;

struct PawnTypeStruct
{
    var string FriendlyName;
    var class<Pawn> PawnClass;
    var class<Pawn> CeilingPawnClass;
    var class<Controller> ControllerClass;
    var int Level;
    var int Points;
    var int StartHealth;
    var int NormalHealth;
    var int Cooldown;
};
var array<PawnTypeStruct> ConstructionTypes;

struct ReplicatedPawnTypeStruct
{
    var string FriendlyName;
    var int Points;
};

struct PawnSpawnOffset
{
  var class<Pawn> PawnClass;
  var vector SpawnOffset;
  var vector CeilingSpawnOffset;
};
var array<PawnSpawnOffset> ConstructionSpawnOffsets;

var localized string SelectionTitle;

var float FastBuildPercent;
var int SelectedCooldown;

var int BlocksSpawned; //set while spawning multi-blocks to calculate cooldown if some don't spawn

const MSG_NeedTrans = 0x0010;
const MSG_NeedDeploy = 0x0020;
const MSG_NoSurface = 0x0030;
const MSG_NoRoom = 0x0040;
const MSG_Max = 0x0050;
const MSG_TooManyExtra = 0x0060;
const MSG_NotEnough = 0x0070;
const MSG_NotHighEnoughLevel = 0x0080;

var localized string
    Msg_Text_NeedTrans,
    Msg_Text_NeedDeploy,
    Msg_Text_NoSurface,
    Msg_Text_NoRoom,
    Msg_Text_Max,
    Msg_Text_TooManyExtra,
    Msg_Text_NotEnough,
    Msg_Text_NotHighEnoughLevel;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientReceiveConstructTypes;
}

static final function vector GetSpawnOffset(class<Pawn> PawnClass, bool bOnCeiling, ArtifactBase_EngineerSummon A)
{
    local int i;

    for(i = 0; i < A.ConstructionSpawnOffsets.Length; i++)
    {
        if(PawnClass == A.ConstructionSpawnOffsets[i].PawnClass)
        {
            if(!bOnCeiling)
                return A.ConstructionSpawnOffsets[i].SpawnOffset;
            else
                return A.ConstructionSpawnOffsets[i].CeilingSpawnOffset;
        }
    }
    return vect(0, 0, 0);
}

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_FailedToSpawn:
            return default.MsgFailedToSpawn;
        case MSG_NeedTrans:
            return default.Msg_Text_NeedTrans;
        case MSG_NeedDeploy:
            return default.Msg_Text_NeedDeploy;
        case MSG_NoSurface:
            return default.Msg_Text_NoSurface;
        case MSG_NoRoom:
            return default.Msg_Text_NoRoom;
        case MSG_Max:
            return default.Msg_Text_Max;
        case MSG_TooManyExtra:
            return default.Msg_Text_TooManyExtra;
        case MSG_NotEnough:
            return default.Msg_Text_NotEnough;
        case MSG_NotHighEnoughLevel:
            return default.Msg_Text_NotHighEnoughLevel;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

function ServerSendConstructionTypes()
{
    local int i;
    local ReplicatedPawnTypeStruct T;

    for(i = 0; i < ConstructionTypes.Length; i++)
    {
        T.FriendlyName = ConstructionTypes[i].FriendlyName;
        T.Points = ConstructionTypes[i].Points;
        ClientReceiveConstructTypes(i, T);
    }
}

simulated function ClientReceiveConstructTypes(int i, ReplicatedPawnTypeStruct T)
{
    local int x;

    if(Role < ROLE_Authority)
    {
        if(i == 0)
            ConstructionTypes.Length = 0;

        x = ConstructionTypes.Length;
        ConstructionTypes.Length = x + 1;
        ConstructionTypes[x].FriendlyName = T.FriendlyName;
        ConstructionTypes[x].Points = T.Points;
    }
}

function bool CanActivate()
{
    if(SelectedOption < 0)
        CostPerSec = 0; //no cost until selection

    if(!Super.CanActivate() || InstigatorRPRI == None)
        return false;

    switch(ConstructionType)
    {
        case "BUILDING":
            if(InstigatorRPRI.Buildings.Length >= InstigatorRPRI.MaxBuildings)
            {
                Msg(MSG_Max);
                ResetSelectionOptions();
                return false;
            }
            if(InstigatorRPRI.BuildingPoints - Points < 0)
            {
                Msg(MSG_NotEnough);
                ResetSelectionOptions();
                return false;
            }
            return true;
        case "SENTINEL":
            if(InstigatorRPRI.Sentinels.Length >= InstigatorRPRI.MaxSentinels)
            {
                Msg(MSG_Max);
                ResetSelectionOptions();
                return false;
            }
            if(InstigatorRPRI.SentinelPoints - Points < 0)
            {
                Msg(MSG_NotEnough);
                ResetSelectionOptions();
                return false;
            }
            return true;
        case "TURRET":
            if(InstigatorRPRI.Turrets.Length >= InstigatorRPRI.MaxTurrets)
            {
                Msg(MSG_Max);
                ResetSelectionOptions();
                return false;
            }
            if(InstigatorRPRI.TurretPoints - Points < 0)
            {
                Msg(MSG_NotEnough);
                ResetSelectionOptions();
                return false;
            }
            return true;
        case "VEHICLE":
            if(InstigatorRPRI.Vehicles.Length >= InstigatorRPRI.MaxVehicles)
            {
                Msg(MSG_Max);
                ResetSelectionOptions();
                return false;
            }
            if(InstigatorRPRI.VehiclePoints - Points < 0)
            {
                Msg(MSG_NotEnough);
                ResetSelectionOptions();
                return false;
            }
            return true;
        case "UTILITY":
            if(InstigatorRPRI.Utilities.Length >= InstigatorRPRI.MaxUtilities)
            {
                Msg(MSG_Max);
                ResetSelectionOptions();
                return false;
            }
            if(InstigatorRPRI.UtilityPoints - Points < 0)
            {
                Msg(MSG_NotEnough);
                ResetSelectionOptions();
                return false;
            }
            return true;
        default:
            return false;
    }
}

function OnSelection(int i)
{
    Points = ConstructionTypes[i].Points;
    StartHealth = ConstructionTypes[i].StartHealth;
    NormalHealth = ConstructionTypes[i].NormalHealth;
    SelectedCooldown = ConstructionTypes[i].Cooldown;
    SpawnActorClass = ConstructionTypes[i].PawnClass;
    SpawnActorClassCeiling = ConstructionTypes[i].CeilingPawnClass;
    SpawnControllerClass = ConstructionTypes[i].ControllerClass;

    if(SpawnActorClassCeiling == None)
        SpawnActorClassCeiling = SpawnActorClass;
}

simulated function string GetSelectionTitle()
{
    return SelectionTitle;
}

simulated function int GetNumOptions()
{
    return ConstructionTypes.Length;
}

simulated function string GetOption(int i)
{
    if(i < ConstructionTypes.Length)
        return ConstructionTypes[i].FriendlyName;
    return "";
}

simulated function int GetOptionCost(int i)
{
    return ConstructionTypes[i].Points;
}

simulated function array<OptionCostStruct> GetHUDOptionCosts(int i)
{
    local OptionCostStruct OptionCost;
    local array<OptionCostStruct> OptionCosts;

    OptionCost.Cost = GetOptionCost(i);
    switch(ConstructionType)
    {
        case "BUILDING":
            OptionCost.Icon = Texture'BuildingPointsIcon';
            OptionCost.bCanAfford = InstigatorRPRI.BuildingPoints - OptionCost.Cost >= 0;
            break;
        case "SENTINEL":
            OptionCost.Icon = Texture'SentinelPointsIcon';
            OptionCost.bCanAfford = InstigatorRPRI.SentinelPoints - OptionCost.Cost >= 0;
            break;
        case "TURRET":
            OptionCost.Icon = Texture'TurretPointsIcon';
            OptionCost.bCanAfford = InstigatorRPRI.TurretPoints - OptionCost.Cost >= 0;
            break;
        case "VEHICLE":
            OptionCost.Icon = Texture'VehiclePointsIcon';
            OptionCost.bCanAfford = InstigatorRPRI.VehiclePoints - OptionCost.Cost >= 0;
            break;
        case "UTILITY":
            OptionCost.Icon = Texture'UtilityPointsIcon';
            OptionCost.bCanAfford = InstigatorRPRI.UtilityPoints - OptionCost.Cost >= 0;
            break;
    }

    OptionCosts[0] = OptionCost;
    return OptionCosts;
}

function ResetSelectionOptions()
{
    Points = 0;
    StartHealth = 0;
    NormalHealth = 0;
    Cooldown = 0;
    SpawnActorClass = None;
    SpawnActorClassCeiling = None;
    SpawnControllerClass = None;
}

function bool DoEffect()
{
    local TranslocatorBeacon tb,TempBeacon;
    local TransLauncher tr;

    if(Instigator == None)
        return false;

    if(Instigator.Weapon == None || (TransLauncher(Instigator.Weapon) == None && !(InStr(Caps(Instigator.Weapon.ItemName), "TRANSLOCATOR") > -1)))
    {
        Msg(MSG_NeedTrans);
        return false;
    }
    if(TransLauncher(Instigator.Weapon) != None)
    {
        tr = TransLauncher(Instigator.Weapon);
        tb = tr.TransBeacon;
    }
    else
    {
        // prob UT2003 translocator. Cant get at the transbeacon through the weapon. Lets do a global search
        foreach DynamicActors(class'TranslocatorBeacon', TempBeacon)
        {
            if(TempBeacon.InstigatorController == Instigator.Controller && TempBeacon.InstigatorController != None)
            {
                tb = TempBeacon;
                break;
            }
        }
    }
    if(tb == None) // no beacon out, so can't spawn
    {
        Msg(MSG_NeedDeploy);
        return false;
    }

    // let try to summon it. If it works, bring back the beacon.
    if(SpawnIt(tb, Instigator))
    {
        // successfully summoned something
        if(tr != None)
        {
            tr.TransBeacon.Destroy();
            tr.TransBeacon = None;
        }
        else
        {
            // prob UT2003 trans, but cant reset directly. Lets just destroy the object
            tb.Destroy();
        }
        ResetSelectionOptions();
        return true;
    }
    ResetSelectionOptions();
}

final function bool CheckSpace(vector SpawnLocation, int HorizontalSpaceReqd, int VerticalSpaceReqd)
{
    // check to see that we have the required space around the trans in at least two adjactent directions, and up
    if(!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 0, 1) * VerticalSpaceReqd)))
        return false;

    if(!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 1, 0) * HorizontalSpaceReqd))
        && !FastTrace(SpawnLocation, SpawnLocation - (vect(0, 1, 0) * HorizontalSpaceReqd)))
        return false;

    if(!FastTrace(SpawnLocation, SpawnLocation + (vect(1, 0, 0) * HorizontalSpaceReqd))
        && !FastTrace(SpawnLocation, SpawnLocation - (vect(1, 0, 0) * HorizontalSpaceReqd)))
        return false;

    // should be room
    return true;
}

final function SetStartHealth(Pawn NewItem)
{
    if(StartHealth > 0 && NewItem != None)
    {
        if( TeamGame(Level.Game) != None && Bot(Instigator.Controller) == None)
        {
            NewItem.Health = StartHealth;
            NewItem.HealthMax = NormalHealth;
        }
        else
        {
            // if not teamgame, then link will not heal, so start at full health. Also bots will not heal, so set bot constructs to full health
            NewItem.Health = NormalHealth;
            NewItem.HealthMax = NormalHealth;
        }
    }
    NewItem.SuperHealthMax = NewItem.HealthMax; // set to non-199 so can pickup later
}

final function vector GetSpawnHeight(vector BeaconLocation)
{
    // hack to ensure turrets aren't spawned too high in the air.
    local vector DownEndLocation;
    local vector HitLocation;
    local vector HitNormal;
    local Actor AHit;

    DownEndLocation = BeaconLocation + vect(0, 0, -300);

    // See if we hit something.
    AHit = Trace(HitLocation, HitNormal, DownEndLocation, BeaconLocation, true);
    if(AHit == None || !AHit.bWorldGeometry)
        return vect(0, 0, 0); // invalid, nothing to spawn on
    else
        return HitLocation;
}

final function vector FindCeiling(vector BeaconLocation)
{
    // hack to ensure turrets aren't spawned too high in the air.
    local vector UpEndLocation;
    local vector HitLocation;
    local vector HitNormal;
    local Actor AHit;

    UpEndLocation = BeaconLocation + vect(0, 0, 300);

    // See if we hit something.
    AHit = Trace(HitLocation, HitNormal, UpEndLocation, BeaconLocation, true);
    if(AHit == None || !AHit.bWorldGeometry)
        return vect(0,0,0); // invalid, nothing to spawn on
    else
        return HitLocation;
}

final function bool CheckMultiBlock(int BuildingPoints, int NumBlocks, Pawn P)
{
    if(BuildingPoints - NumBlocks < 0)
    {
        Msg(MSG_NotEnough);
        return false;
    }
    return true;
}

final function bool SpawnIt(TranslocatorBeacon Beacon, Pawn P)
{
    local class<Pawn> SpawnClass;
    local Controller C;
    local Pawn Spawned;
    local vector SpawnLoc,SpawnLocCeiling;
    local rotator SpawnRot;
    local bool bGotSpace;
    local int i;
    local RPGBlock NewBlock;
    local bool bOnCeiling;
    local vector Normalvect, XVect, YVect, ZVect, OffsetVect;
    local vector BlockLoc;
    local int PointsForEach;
    local bool bRequiresSurface;

    SpawnClass = class<Pawn>(SpawnActorClass);
    if(SpawnClass == None)
        return false;

    if(ClassIsChildOf(SpawnActorClass,class'RPGEnergyWall'))
        return SpawnEnergyWall(Beacon, P);

    if(ClassIsChildOf(SpawnClass, class'RPGSentinel') ||
        ClassIsChildOf(SpawnClass, class'RPGDefenseSentinel') ||
        ClassIsChildOf(SpawnClass, class'RPGLightningSentinel') ||
        ClassIsChildOf(SpawnClass, class'RPGLinkSentinel') ||
        ClassIsChildOf(SpawnClass, class'ASTurret') ||
        ClassIsChildOf(SpawnClass, class'ONSManualGunPawn'))
    {
        bRequiresSurface = True;
        SpawnLoc = GetSpawnHeight(Beacon.Location); // look at the floor
    }
    else
        SpawnLoc = Beacon.Location;

    if(ClassIsChildOf(SpawnClass, class'RPGSentinel') || ClassIsChildOf(SpawnClass, class'RPGDefenseSentinel')
         || ClassIsChildOf(SpawnClass, class'RPGLightningSentinel') || ClassIsChildOf(SpawnClass, class'RPGLinkSentinel')
         || ClassIsChildOf(SpawnClass, class'RPGAutoGun'))
    {
        // need to check if ceiling variant is required
        SpawnLocCeiling = FindCeiling(Beacon.Location); // its a ceiling sentinel - special case.
        if(SpawnLocCeiling != vect(0, 0, 0)
            && (SpawnLoc == vect(0, 0, 0) || VSize(SpawnLocCeiling - Beacon.Location) < VSize(SpawnLoc - Beacon.Location)))
        {
            // its the ceiling one we want
            bOnCeiling = true;
            SpawnClass = class<Pawn>(SpawnActorClassCeiling);
            SpawnLoc = SpawnLocCeiling;
            // flip over sentinels with no actual ceiling variant
            if(ClassIsChildOf(SpawnClass, class'RPGLinkSentinel') || ClassIsChildOf(SpawnClass, class'RPGAutoGun'))
            {
                SpawnRot.Roll = 32768; // upside down
            }
            bGotSpace = CheckSpace(SpawnLoc, SpawnClass.default.CollisionRadius, -SpawnClass.default.CollisionHeight);
        }
        else
            bGotSpace = CheckSpace(SpawnLoc, SpawnClass.default.CollisionRadius, SpawnClass.default.CollisionHeight);
    }
    else
        bGotSpace = CheckSpace(SpawnLoc, SpawnClass.default.CollisionRadius, SpawnClass.default.CollisionHeight);

    if(!bGotSpace)
    {
        MSG(MSG_NoRoom);
        return false;
    }

    if(bRequiresSurface && SpawnLoc == vect(0, 0, 0))
    {
        MSG(MSG_NoSurface);
        return false;
    }

    // not SpawnClass because we want to reference the original summon in case we modify it
    SpawnLoc += static.GetSpawnOffset(class<Pawn>(SpawnActorClass), bOnCeiling, Self);
    SpawnRot.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;

    if(ClassIsChildOf(SpawnClass, class'RPGMultiBlock'))
    {
        // lots of blocks
        SpawnLoc = Beacon.Location;

        // do not check for space - each block gets checked separately

        if(!CheckMultiBlock(InstigatorRPRI.BuildingPoints, class<RPGMultiBlock>(SpawnClass).default.NumBlocks, P))
        {
            // message already generated
            return false;
        }
        // ok, can do
        NormalVect = Normal(SpawnLoc - Instigator.Location);
        NormalVect.Z = 0;
        YVect = NormalVect;
        ZVect = vect(0, 0, 1); // always vertical
        XVect = Normal(YVect cross ZVect); // vector at 90 degrees to the other two
        PointsForEach = Points/Points;

        for (i = 0; i < class<RPGMultiBlock>(SpawnClass).default.NumBlocks; i++)
        {
            OffsetVect = (XVect * class<RPGMultiBlock>(SpawnClass).default.Blocks[i].XOffset) + (YVect * class<RPGMultiBlock>(SpawnClass).default.Blocks[i].YOffset) + (ZVect * class<RPGMultiBlock>(SpawnClass).default.Blocks[i].ZOffset);
            BlockLoc = SpawnLoc + OffsetVect;

            // check what angle to spawn it at
            switch(class<RPGMultiBlock>(SpawnClass).default.Blocks[i].Angle)
            {
                case 1:
                    // right angle to vector player to trans
                    SpawnRot.Yaw = rotator(XVect).Yaw;
                    break;
                case 2:
                    // facing player
                    SpawnRot.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;
                    break;
                case 3:
                    // facing trans point
                    SpawnRot.Yaw = rotator(BlockLoc - SpawnLoc).Yaw;
                    break;
                default:
                    // do it straight facing the player from the trans point
                    SpawnRot.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;
                    break;
            }

            BlocksSpawned = 0;
            NewBlock = RPGBlock(SpawnActor(class<RPGMultiBlock>(SpawnClass).default.Blocks[i].BlockType, BlockLoc, SpawnRot));
            if(NewBlock != None)
            {
                NewBlock.PlayerSpawner = Instigator.Controller;

                BlocksSpawned++;

                if(InstigatorRPRI != None)
                    InstigatorRPRI.AddConstruction(ConstructionType, NewBlock, PointsForEach);

                SetStartHealth(NewBlock);

                if(i == 0)
                    NewBlock.Spawn(class'FX_ConstructionSpawn', NewBlock,, NewBlock.Location, NewBlock.Rotation).PlaySound(sound'SpawnConstruction', SLOT_Misc, 255,, 256);
                else
                    NewBlock.Spawn(class'FX_ConstructionSpawn', NewBlock,, NewBlock.Location, NewBlock.Rotation);
            }
            NewBlock = None;
        }
        return true;
    }

    Spawned = Pawn(SpawnActor(SpawnClass, SpawnLoc, SpawnRot));
    if(Spawned != None)
    {
        if(Vehicle(Spawned) != None)
        {
            Vehicle(Spawned).SetTeamNum(Instigator.GetTeamNum());
            Spawned.SetOwner(None); //vehicles without a controller will report death of Controller(Owner) if they have one; causes major issues
        }

        if(Spawned.Controller != None)
            Spawned.Controller.Destroy();

        if(SpawnControllerClass != None)
            C = Spawn(SpawnControllerClass,,, SpawnLoc, Spawned.Rotation);
        if(C != None)
        {
            if(Vehicle(Spawned) != None)
            {
                Vehicle(Spawned).bAutoTurret = true;
                Vehicle(Spawned).bNonHumanControl = true;
            }

            if(RPGAutoGunController(C) != None)
                RPGAutoGunController(C).SetPlayerSpawner(Instigator.Controller);
            else if(RPGDefenseSentinelController(C) != None)
                RPGDefenseSentinelController(C).SetPlayerSpawner(Instigator.Controller);
            else if(RPGLightningSentinelController(C) != None)
                RPGLightningSentinelController(C).SetPlayerSpawner(Instigator.Controller);
            else if(RPGLinkSentinelController(C) != None)
                RPGLinkSentinelController(C).SetPlayerSpawner(Instigator.Controller);
            else if(RPGBaseSentinelController(C) != None)
                RPGBaseSentinelController(C).SetPlayerSpawner(Instigator.Controller);
            else if(RPGSentinelController(C) != None)
                RPGSentinelController(C).SetPlayerSpawner(Instigator.Controller);
            else if(RPGFieldGeneratorController(C) != None)
                RPGFieldGeneratorController(C).SetPlayerSpawner(Instigator.Controller);
            C.Possess(Spawned);
        }

        if(Spawned.PlayerReplicationInfo != None)
            Spawned.PlayerReplicationInfo.Team = Instigator.GetTeam();

        if(RPGBlock(Spawned) != None)
            RPGBlock(Spawned).PlayerSpawner = Instigator.Controller;

        if(InstigatorRPRI != None)
            InstigatorRPRI.AddConstruction(ConstructionType, Spawned, Points);

        SetStartHealth(Spawned);
        Spawned.Spawn(class'FX_ConstructionSpawn', Spawned,, Spawned.Location, Spawned.Rotation).PlaySound(sound'SpawnConstruction', SLOT_Misc, 255,, 128);
    }
    return (Spawned != None);
}

final function bool SpawnEnergyWall(TranslocatorBeacon Beacon, Pawn P)
{
    Local RPGEnergyWall NewEnergyWall;
    local RPGEnergyWallController EWC;
    local Actor A;
    local vector HitLocation, HitNormal;
    local vector Post1SpawnLoc, Post2SpawnLoc, SpawnLoc;
    local vector Normalvect, XVect, YVect, ZVect;
    local class<RPGEnergyWall> WallSummonItem;

    WallSummonItem = class<RPGEnergyWall>(SpawnActorClass);
    if(WallSummonItem == None)
    {
        Msg(MSG_FailedToSpawn);
        return false;
    }

    SpawnLoc = GetSpawnHeight(Beacon.Location); // look at the floor
    if(SpawnLoc == vect(0, 0, 0))
    {
        MSG(MSG_NoSurface);
        return false;
    }
    SpawnLoc.z += 20 + (WallSummonItem.default.Height * 0.5f); // step up a bit off the ground

    // now work out the position of the posts
    NormalVect = Normal(SpawnLoc - Instigator.Location);
    NormalVect.Z = 0;
    YVect = NormalVect;
    ZVect = vect(0, 0, 1); // always vertical
    XVect = Normal(YVect cross ZVect); // vector at 90 degrees to the other two

    // first check the height
    if(!FastTrace(SpawnLoc, SpawnLoc + (ZVect * WallSummonItem.default.Height)))
    {
        Msg(MSG_NoRoom);
        return false;
    }

    A = Trace(HitLocation, HitNormal, SpawnLoc + (XVect * WallSummonItem.default.MaxGap * 0.5), SpawnLoc, true);
    if(A == None)
        Post1SpawnLoc = SpawnLoc + (XVect * WallSummonItem.default.MaxGap * 0.5);
    else
        Post1SpawnLoc = HitLocation - 20 * XVect; // step back slightly from the object

    A = None;
    A = Trace(HitLocation, HitNormal, SpawnLoc - (XVect * WallSummonItem.default.MaxGap * 0.5), SpawnLoc, true);
    if(A == None)
        Post2SpawnLoc = SpawnLoc - (XVect * WallSummonItem.default.MaxGap * 0.5);
    else
        Post2SpawnLoc = HitLocation + 20 * XVect; // step back slightly from the object

    // ok now lets spawn it
    if((Post1SpawnLoc == vect(0, 0, 0)) || (Post2SpawnLoc == vect(0, 0, 0)) || VSize(Post1SpawnLoc - Post2SpawnLoc) > WallSummonItem.default.MaxGap || VSize(Post1SpawnLoc - Post2SpawnLoc) < WallSummonItem.default.MinGap)
    {
        // cant spawn one of the posts or one has gone awol
        Msg(MSG_NoSurface);
        return false;
    }

    // have 2 valid post positions and a gap inbetween
    NewEnergyWall = SummonEnergyWall(WallSummonItem, P, SpawnLoc, Post1SpawnLoc, Post2SpawnLoc);
    if(NewEnergyWall == None)
        return false;
    SetStartHealth(NewEnergyWall);

    // now lets add the controller
    if( Role == Role_Authority )
    {
        // create the controller for this energy wall
        EWC = RPGEnergyWallController(Spawn(NewEnergyWall.default.DefaultController));
        if( EWC != None )
        {
            EWC.SetPlayerSpawner(Instigator.Controller);
            EWC.Possess(NewEnergyWall);

            // now allow player to get xp bonus
            if(InstigatorRPRI != None)
                InstigatorRPRI.AddConstruction(ConstructionType, NewEnergyWall, Points);
        }
    }
    return true;
}

final function RPGEnergyWall SummonEnergyWall(class<RPGEnergyWall> ChosenEWall, Pawn P, vector SpawnLocation, vector P1Loc, vector P2Loc)
{
    local RPGEnergyWall E;
    local rotator SpawnRotation;
    local RPGEnergyWallPost Post1,Post2;

    // lets create the posts
    Post1 = Spawn(ChosenEWall.default.DefaultPost, P,, P1Loc);
    if(Post1 == None)
    {
        // lets retry a bit further away from the edge
        P1Loc = P1Loc + (10 * Normal(P2Loc - P1Loc));
        Post1 = Spawn(ChosenEWall.default.DefaultPost, P,, P1Loc);
        if(Post1 == None)
        {
            Msg(MSG_FailedToSpawn);
            return None;
        }
    }
    Post2 = Spawn(ChosenEWall.default.DefaultPost,P,, P2Loc);
    if(Post2 == None)
    {
        // lets retry a bit further away from the edge
        P2Loc = P2Loc + (10 * Normal(P1Loc - P2Loc));
        Post2 = Spawn(ChosenEWall.default.DefaultPost, P,, P2Loc);
        if(Post2 == None)
        {
            Post1.Destroy();
            Msg(MSG_FailedToSpawn);
            return None;
        }
    }

    // ok, got 2 posts so spawn the wall between
    SpawnRotation.Yaw = rotator(SpawnLocation - Instigator.Location).Yaw;
    SpawnLocation = (P1Loc + P2Loc) * 0.5f;
    SpawnLocation.Z -= 22;

    E = Spawn(ChosenEWall, P,, SpawnLocation, SpawnRotation); // position halfway between the posts
    if(E == None)
    {
        Post1.Destroy();
        Post2.Destroy();
        Msg(MSG_FailedToSpawn);
        return None;
    }

    E.P1Loc = P1Loc;
    E.P2Loc = P2Loc;
    E.SetTeamNum(P.GetTeamNum());
    if(E.Controller != None)
        E.Controller.Destroy();

    return E;
}

function DoCooldown()
{
    local Artifact_EngineerBuildingSummon BSummon;
    local Artifact_EngineerSentinelSummon SSummon;
    local Artifact_EngineerTurretSummon TSummon;
    local Artifact_EngineerVehicleSummon VSummon;
    local Artifact_EngineerUtilitySummon USummon;
    local Inventory Inv;

    if(ClassIsChildOf(SpawnActorClass,class'RPGMultiBlock'))
    {
        if(BlocksSpawned == 0)
            Cooldown = 0;
        else
            Cooldown = SelectedCooldown / (class<RPGMultiBlock>(SpawnActorClass).default.NumBlocks / BlocksSpawned);
    }
    else
        Cooldown = SelectedCooldown * FastBuildPercent;

    for(Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if(Artifact_EngineerBuildingSummon(Inv) != None)
            BSummon = Artifact_EngineerBuildingSummon(Inv);
        else if(Artifact_EngineerSentinelSummon(Inv) != None)
            SSummon = Artifact_EngineerSentinelSummon(Inv);
        else if(Artifact_EngineerTurretSummon(Inv) != None)
            TSummon = Artifact_EngineerTurretSummon(Inv);
        else if(Artifact_EngineerVehicleSummon(Inv) != None)
            VSummon = Artifact_EngineerVehicleSummon(Inv);
        else if(Artifact_EngineerUtilitySummon(Inv) != None)
            USummon = Artifact_EngineerUtilitySummon(Inv);

        if(BSummon != None && SSummon != None && TSummon != None && VSummon != None && USummon != None)
            break;
    }

    if(BSummon != None)
    {
        BSummon.Cooldown = Cooldown;
        BSummon.NextUseTime = Level.TimeSeconds + Cooldown;
        BSummon.ClientNotifyCooldown(Cooldown);
    }
    if(SSummon != None)
    {
        SSummon.Cooldown = Cooldown;
        SSummon.NextUseTime = Level.TimeSeconds + Cooldown;
        SSummon.ClientNotifyCooldown(Cooldown);
    }
    if(TSummon != None)
    {
        TSummon.Cooldown = Cooldown;
        TSummon.NextUseTime = Level.TimeSeconds + Cooldown;
        TSummon.ClientNotifyCooldown(Cooldown);
    }
    if(VSummon != None)
    {
        VSummon.Cooldown = Cooldown;
        VSummon.NextUseTime = Level.TimeSeconds + Cooldown;
        VSummon.ClientNotifyCooldown(Cooldown);
    }
    if(USummon != None)
    {
        USummon.Cooldown = Cooldown;
        USummon.NextUseTime = Level.TimeSeconds + Cooldown;
        USummon.ClientNotifyCooldown(Cooldown);
    }
}

exec function Build(string Chosen)
{
    local int i;

    for(i = 0; i < ConstructionTypes.Length; i++)
    {
        if(ConstructionTypes[i].FriendlyName ~= Repl(Chosen, "_", " "))
        {
            SelectedOption = i;
            Points = ConstructionTypes[i].Points;
            StartHealth = ConstructionTypes[i].StartHealth;
            NormalHealth = ConstructionTypes[i].NormalHealth;
            SelectedCooldown = ConstructionTypes[i].Cooldown;
            SpawnActorClass = ConstructionTypes[i].PawnClass;
            SpawnControllerClass = ConstructionTypes[i].ControllerClass;
            Activate();
            return;
        }
    }
}

defaultproperties
{
    Msg_Text_NeedTrans="You need to be using the Translocator for this artifact to operate."
    Msg_Text_NeedDeploy="You need to have the Translocator beacon deployed to use this artifact."
    Msg_Text_NoSurface="There is nothing to spawn the item on."
    Msg_Text_NoRoom="There is not enough room around the spawn location."
    Msg_Text_Max="You have summoned too many of these. You must kill one before you can summon another one."
    Msg_Text_TooManyExtra="You cannot spawn this many extra items."
    Msg_Text_NotEnough="Insufficient points available to summon this."
    Msg_Text_NotHighEnoughLevel="You are not a high enough level to summon this."
    ClearRadius=48.000000
    BlockingTypes(8)=None
    BlockingTypeStrings(8)=""
    FastBuildPercent=1.000000
    bShowFailureMessage=False
    MsgFailedToSpawn="Failed to spawn."
    bSelection=True
    bCanBeTossed=False
    MinAdrenaline=0
    CostPerSec=0
    SelectionTitle="Pick something to construct:"
    ArtifactID="Summonifact"
    ItemName="Engineer Summoning Artifact"
    Description="Constructs something."
}
