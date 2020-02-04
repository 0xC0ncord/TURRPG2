//If you were looking for RPGStatsInv, this replaces it. ~pd
class RPGPlayerReplicationInfo extends LinkedReplicationInfo
    DependsOn(RPGAbility)
    DependsOn(RPGCharSettings)
    config(TURRPG2);

//server
var RPGData DataObject;
var MutTURRPG RPGMut;

var bool bImposter;

//PDP protection
var array<class<Weapon> > ThrownWeapons;

var RPGAIBuild AIBuild;
var int AIBuildAction;

var RPGPlayerLevelInfo PlayerLevel;

//Status icons
var array<RPGStatusIcon> Status;

struct ArtifactCooldown
{
    var class<RPGArtifact> AClass;
    var float TimeLeft;
};
var array<ArtifactCooldown> SavedCooldown;

//Favorite Weapons
var array<RPGCharSettings.FavoriteWeaponStruct> FavoriteWeapons;

//Weapon and Artifact Restoration
var class<Powerups> LastSelectedPowerupType;
var RPGCharSettings.FavoriteWeaponStruct LastSelectedWeapon;

var Weapon SwitchToWeapon; //client

/*
    Weapon granting queue

    Abilities should no longer directly give weapons to the player, but queue them up
    using QueueWeapon. This allows for central handling of managing granted weapons, e.g.
    by the Favorite Weapon feature
*/
struct GrantWeapon
{
    var class<Weapon> WeaponClass;
    var class<RPGWeaponModifier> ModifierClass;
    var int Modifier;
    var int Ammo[2]; //extra ammo per fire mode. 0 = none, -1 = full
    var bool bForce;
};
var array<GrantWeapon> GrantQueue, GrantFavQueue;

//parallel daredevil points counter
var int DaredevilPoints;

//to detect team changes
var int Team; //info holder for RPGRules, set each spawn
var bool bTeamChanged; //set by RPGRules, reset each spawn

//to detect weapon switches
var Weapon LastPawnWeapon;

//stuff that belongs to me
struct ConstructionStruct
{
    var Pawn Pawn;
    var int Points;
};
var array<ConstructionStruct> Buildings;
var array<ConstructionStruct> Sentinels;
var array<ConstructionStruct> Turrets;
var array<ConstructionStruct> Vehicles;
var array<ConstructionStruct> Utilities;
var array<ConstructionStruct> Monsters;

//engineer stuff
var array<Vehicle> LockedVehicles;
var array<Controller> VehicleHealers;
var int NumVehicleHealers;
var float LastVehicleHealTime;

//replicated
var int NumMonsters;
var int NumBuildings, NumSentinels, NumTurrets;
var int NumVehicles, NumUtilities;

//stats
var int MaxMonsters;
var int MaxBuildings, MaxSentinels, MaxTurrets;
var int MaxVehicles, MaxUtilities;
var int MonsterPoints, MaxMonsterPoints;
var int BuildingPoints, MaxBuildingPoints;
var int SentinelPoints, MaxSentinelPoints;
var int TurretPoints, MaxTurretPoints;
var int VehiclePoints, MaxVehiclePoints;
var int UtilityPoints, MaxUtilityPoints;

//determine if summons die on player death
var bool bMonstersDie;
var bool bBuildingsDie;
var bool bSentinelsDie;
var bool bTurretsDie;
var bool bVehiclesDie;
var bool bUtilitiesDie;

var float HealingExpMultiplier;

//projectile handling
const PROJ_SEARCH_RADIUS = 2048;

struct ProjectileMod {
    var int NumTicks;

    var vector Location;
    var class<Projectile> Type;
    var Pawn Instigator;

    var float Vel;
    var name Flag;
    var class<Emitter> FXClass;
};
var array<ProjectileMod> ModifyProjectiles;

//replicated server->client
var Controller Controller;
var PlayerReplicationInfo PRI;

var string RPGName;
var int RPGLevel, NeededExp;
var int StatPointsAvailable, AbilityPointsAvailable;
var float Experience;
var array<RPGAbility> Abilities;

var bool bGameEnded;

//replicated client->server
struct ArtifactOrderStruct
{
    var class<RPGArtifact> ArtifactClass;
    var string ArtifactID;
    var bool bShowAlways;
    var bool bNeverShow;
};
var array<ArtifactOrderStruct> ArtifactOrder;

//artifact radial menu (client-side)
struct RadialMenuArtifactStruct
{
    var class<RPGArtifact> ArtifactClass;
    var string ArtifactID;
    var bool bShowAlways;
};
var array<RadialMenuArtifactStruct> ArtifactRadialMenuOrder;

//rebuild info
var bool bAllowRebuild;
var int RebuildCost;
var int RebuildMaxLevelLoss;

//client
var bool bClientSetup;
var bool bClientSyncDone;

var RPGInteraction Interaction;
var RPGMenu Menu;

var int AbilitiesReceived, AbilitiesTotal;

var array<RPGAbility> AllAbilities;
var array<class<RPGArtifact> > AllArtifacts;

//adrenaline gain modification
var int AdrenalineBeforeKill;

//Sound
var Sound LevelUpSound;

//Materials
var Material LockedVehicleOverlay;

//Text
var localized string GameRestartingText, ImposterText, LevelUpText, IntroText;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Controller, RPGName,
        bAllowRebuild, RebuildCost, RebuildMaxLevelLoss;
    reliable if(Role == ROLE_Authority && bNetDirty)
        bImposter, RPGLevel, Experience, NeededExp,
        StatPointsAvailable, AbilityPointsAvailable,
        bGameEnded,
        NumMonsters,
        MaxMonsters,
        NumBuildings, NumSentinels, NumTurrets, NumVehicles, NumUtilities,
        MaxBuildings, MaxSentinels, MaxTurrets, MaxVehicles, MaxUtilities,
        MonsterPoints, MaxMonsterPoints,
        BuildingPoints, MaxBuildingPoints, SentinelPoints, MaxSentinelPoints,
        TurretPoints, MaxTurretPoints, VehiclePoints, MaxVehiclePoints,
        UtilityPoints, MaxUtilityPoints,
        NumVehicleHealers;
    reliable if(Role == ROLE_Authority)
        ClientReInitMenu, ClientEnableRPGMenu,
        ClientNotifyExpGain, ClientShowHint,
        ClientSetName, ClientGameEnded,
        ClientCheckArtifactClass,
        ClientSwitchToWeapon, //moved from TitanPlayerController for better compatibility
        ClientCreateStatusIcon, ClientRemoveStatusIcon,
        ClientShowSelection, ClientCloseSelection, //artifact selection menu
        ClientSyncProjectile;
    reliable if(Role < ROLE_Authority)
        ServerBuyAbility, ServerNoteActivity,
        ServerSwitchBuild, ServerResetData, ServerRebuildData,
        ServerClearArtifactOrder, ServerAddArtifactOrderEntry, ServerSortArtifacts,
        ServerGetArtifact, ServerActivateArtifact, //moved from TitanPlayerController for better compatibility
        ServerDestroyBuildings, ServerDestroySentinels, ServerDestroyTurrets,
        ServerDestroyVehicles, ServerDestroyUtilities, ServerKillMonsters;
}

static function RPGPlayerReplicationInfo CreateFor(Controller C)
{
    local PlayerReplicationInfo PRI;
    local RPGPlayerReplicationInfo RPRI;

    PRI = C.PlayerReplicationInfo;

    if(PRI == None)
        return None;

    RPRI = GetForPRI(PRI);
    if(RPRI != None)
    {
        Warn(C.GetHumanReadableName() @ "already has an RPRI!");
        return None;
    }

    RPRI = C.Spawn(class'RPGPlayerReplicationInfo', C);
    RPRI.NextReplicationInfo = PRI.CustomReplicationInfo;
    PRI.CustomReplicationInfo = RPRI;

    return RPRI;
}

static function RPGPlayerReplicationInfo GetForPRI(PlayerReplicationInfo PRI)
{
    local LinkedReplicationInfo LRI;

    if(PRI != None)
    {
        for(LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
        {
            if(RPGPlayerReplicationInfo(LRI) != None)
                return RPGPlayerReplicationInfo(LRI);
        }
    }
    return None;
}

static function RPGPlayerReplicationInfo GetFor(Controller C)
{
    if(C == None)
        return None;

    return GetForPRI(C.PlayerReplicationInfo);
}

//for clients
static function RPGPlayerReplicationInfo GetLocalRPRI(LevelInfo Level)
{
    return GetFor(Level.GetLocalPlayerController());
}

function ModifyStats()
{
    local int x;

    HealingExpMultiplier = class'RPGRules'.default.EXP_Healing;

    for(x = 0; x < Abilities.Length; x++)
    {
        if(Abilities[x].bAllowed)
            Abilities[x].ModifyRPRI();
    }

    if(xPlayer(Controller) != None)
        ModifyCombos();
}

simulated event BeginPlay()
{
    local int i;
    local string PlayerName;
    local RPGData data;

    Super.BeginPlay();

    if(Role == ROLE_Authority)
    {
        Controller = Controller(Owner);
        PRI = Controller.PlayerReplicationInfo;

        RPGMut = class'MutTURRPG'.static.Instance(Level);
        if(RPGMut == None)
        {
            Warn("TURRPG mutator no longer available - cancelling!");
            Destroy();
            return;
        }

        //copy rebuild info for replication
        bAllowRebuild = RPGMut.bAllowRebuild;
        RebuildCost = RPGMut.RebuildCost;
        RebuildMaxLevelLoss = RPGMut.RebuildMaxLevelLoss;

        bGameEnded = false;
        bImposter = false;
        while(true)
        {
            PlayerName = RPGMut.ProcessPlayerName(Self);

            data = RPGData(FindObject("Package." $ PlayerName, class'RPGData'));
            if (data == None)
                data = new(None, PlayerName) class'RPGData';

            if(data.LV == 0) //new player
            {
                data.LV = RPGMut.StartingLevel;
                data.SPA = RPGMut.StartingStatPoints + (Ceil(float(data.LV - 1) / RPGMut.StatPointsIncrement) - 1) * RPGMut.StatPointsPerIncrement;
                data.APA = RPGMut.StartingAbilityPoints + (Ceil(float(data.LV - 1) / RPGMut.AbilityPointsIncrement) - 1) * RPGMut.AbilityPointsPerIncrement;
                data.XN = RPGMut.GetRequiredXpForLevel(data.LV);

                if (PlayerController(Controller) != None)
                    data.ID = PlayerController(Controller).GetPlayerIDHash();
                else
                    data.ID = "Bot";

                break;
            }
            else //returning player
            {
                if((PlayerController(Controller) != None && !(PlayerController(Controller).GetPlayerIDHash() ~= data.ID)) ||
                    (AIController(Controller) != None && data.ID != "Bot"))
                {
                    //imposter using somebody else's name
                    bImposter = true;

                    if(PlayerController(Controller) != None)
                        PlayerController(Controller).ClientOpenMenu("TURRPG2.RPGImposterMessageWindow");

                    //Level.Game.ChangeName(Controller, string(Rand(65535)), true); //That's gotta suck, having a number for a name
                    Level.Game.ChangeName(Controller, Controller.GetHumanReadableName() $ "_Imposter", true);
                }
                else
                    break;
            }
        }

        //Instantiate abilities
        for(i = 0; i < RPGMut.Abilities.Length; i++)
        {
            AllAbilities[i] = Spawn(RPGMut.Abilities[i], Controller);
            AllAbilities[i].RPRI = Self;
            AllAbilities[i].Index = i;
            AllAbilities[i].bIsStat = (class'Util'.static.InArray(RPGMut.Abilities[i], RPGMut.Stats) >= 0);
        }

        LoadData(data);

        if(AIBuild != None)
        {
            if(Bot(Controller) != None)
                AIBuild.InitBot(Bot(Controller));

            AIBuild.Build(Self);
        }

        //Inform others
        PlayerLevel = Spawn(class'RPGPlayerLevelInfo');
        PlayerLevel.PRI = PRI;
        PlayerLevel.RPGLevel = RPGLevel;
        PlayerLevel.Experience = Experience;
        PlayerLevel.ExpNeeded = NeededExp;
    }
}

function Reset() {
    ServerKillMonsters();
    ServerDestroyBuildings();
    ServerDestroySentinels();
    ServerDestroyTurrets();
    ServerDestroyVehicles();
    ServerDestroyUtilities();
}

simulated event Destroyed()
{
    local LinkedReplicationInfo LRI;
    local int i;

    if(PRI != None)
    {
        if(PRI.CustomReplicationInfo == Self)
        {
            PRI.CustomReplicationInfo = NextReplicationInfo;
        }
        else
        {
            for(LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
            {
                if(LRI.NextReplicationInfo == Self)
                {
                    LRI.NextReplicationInfo = NextReplicationInfo;
                    break;
                }
            }
        }
    }

    if(Role == ROLE_Authority)
    {
        for(i = 0; i < AllAbilities.Length; i++)
            AllAbilities[i].Destroy();

        PlayerLevel.Destroy();
    }

    if(Interaction != None)
        Interaction.Remove();

    Interaction = None;
    RPGMut = None;

    Status.Length = 0;
}

simulated function ClientCreateStatusIcon(class<RPGStatusIcon> IconType)
{
    local RPGStatusIcon Icon;
    local int i;

    if(PlayerController(Controller) == None)
        return; //not for bots

    for(i = 0; i < Status.Length; i++)
    {
        if(Status[i].class == IconType)
            return; //already got this one
    }

    Icon = new IconType;
    Icon.RPRI = Self;
    Icon.Initialize();
    Status[Status.Length] = Icon;
}

simulated function ClientRemoveStatusIcon(class<RPGStatusIcon> IconType)
{
    local int i;

    for(i = 0; i < Status.Length; i++)
    {
        if(Status[i].class == IconType)
        {
            Status.Remove(i, 1);
            return;
        }
    }
}

//clients only
simulated function class<RPGArtifact> GetArtifactClass(string ID)
{
    local int i;

    for(i = 0; i < AllArtifacts.Length; i++)
    {
        if(AllArtifacts[i].default.ArtifactID ~= ID)
            return AllArtifacts[i];
    }
    return None;
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(Controller != None && Role == ROLE_Authority)
        Controller.AdrenalineMax = Controller.default.AdrenalineMax; //fix the build switching exploit

    if(Level.NetMode != NM_DedicatedServer)
        ClientSetup(); //try setup. if it fails, it's tried again every tick
}

simulated function ClientSetup()
{
    local int x, i;
    local RPGReplicationInfo RRI;
    local class<RPGArtifact> AClass;
    local ArtifactOrderStruct OrderEntry;
    local RadialMenuArtifactStruct RadialEntry;

    if(Controller == None || Controller.PlayerReplicationInfo == None)
        return; //wait

    RRI = class'RPGReplicationInfo'.static.Get(Level);
    if(Level.NetMode != NM_Standalone && RRI == None)
        return; //wait

    PRI = Controller.PlayerReplicationInfo;

    NextReplicationInfo = PRI.CustomReplicationInfo;
    PRI.CustomReplicationInfo = Self;

    if(xPlayer(Controller) != None)
        ResetCombos();

    if(Role < ROLE_Authority) //not offline
    {
        AbilitiesTotal = RRI.NumAbilities;

        for(x = 0; x < RRI.MAX_Artifacts && RRI.Artifacts[x] != None; x++)
            AllArtifacts[x] = RRI.Artifacts[x];
    }
    else if(Level.NetMode == NM_Standalone) //offline
    {
        AbilitiesTotal = RPGMut.Abilities.Length;
        AllArtifacts = RPGMut.Artifacts;
    }

    if(PlayerController(Controller) != None)
    {
        Interaction = RPGInteraction(
            PlayerController(Controller).Player.InteractionMaster.AddInteraction(
                string(class'RPGInteraction'), PlayerController(Controller).Player));

        if(Interaction != None)
        {
            Interaction.RPRI = Self;

            //build artifact order
            ArtifactOrder.Remove(0, ArtifactOrder.Length);
            ServerClearArtifactOrder();

            if(Interaction.CharSettings != None)
            {
                //load order from settings
                for(x = 0; x < Interaction.CharSettings.ArtifactOrderConfig.Length; x++)
                {
                    AClass = GetArtifactClass(Interaction.CharSettings.ArtifactOrderConfig[x].ArtifactID);

                    OrderEntry.ArtifactClass = AClass;
                    OrderEntry.ArtifactID = Interaction.CharSettings.ArtifactOrderConfig[x].ArtifactID;
                    OrderEntry.bShowAlways = Interaction.CharSettings.ArtifactOrderConfig[x].bShowAlways;
                    OrderEntry.bNeverShow = Interaction.CharSettings.ArtifactOrderConfig[x].bNeverShow;

                    ArtifactOrder[ArtifactOrder.Length] = OrderEntry;
                    ServerAddArtifactOrderEntry(OrderEntry);
                }
                ServerSortArtifacts();

                //load radial menu order from settings
                for(x = 0; x < Interaction.CharSettings.ArtifactRadialMenuConfig.Length; x++)
                {
                    AClass = GetArtifactClass(Interaction.CharSettings.ArtifactRadialMenuConfig[x].ArtifactID);

                    RadialEntry.ArtifactClass = AClass;
                    RadialEntry.ArtifactID = Interaction.CharSettings.ArtifactRadialMenuConfig[x].ArtifactID;
                    RadialEntry.bShowAlways = Interaction.CharSettings.ArtifactRadialMenuConfig[x].bShowAlways;

                    ArtifactRadialMenuOrder[ArtifactRadialMenuOrder.Length] = RadialEntry;
                }

                //load weapon favorites from settings
                FavoriteWeapons = Interaction.CharSettings.FavoriteWeaponsConfig;
            }

            //add all artifacts that were not in the settings to the end
            for(x = 0; x < AllArtifacts.Length; x++)
            {
                i = FindOrderEntry(AllArtifacts[x]);
                if(i == -1)
                {
                    OrderEntry.ArtifactClass = AllArtifacts[x];
                    OrderEntry.ArtifactID = AllArtifacts[x].default.ArtifactID;
                    OrderEntry.bShowAlways = false;

                    ArtifactOrder[ArtifactOrder.Length] = OrderEntry;
                    ServerAddArtifactOrderEntry(OrderEntry);
                }
            }
        }
        else
            Warn("Could not create RPGInteraction!");
    }

    if(AbilitiesReceived >= AbilitiesTotal || Role == ROLE_Authority)
        ClientEnableRPGMenu();

    bClientSetup = true;
}

simulated final function ResetCombos()
{
    local int i;

    //reset the player's combo list
    //without this, combos could potentially be carried across character switches
    for(i = 0; i < 16; i++)
    {
        xPlayer(Controller).ComboNameList[i] = xPlayer(Controller).default.ComboNameList[i];

        if(xPlayer(Controller).ComboNameList[i] != "")
            xPlayer(Controller).ComboList[i] = class<Combo>(DynamicLoadObject(xPlayer(Controller).default.ComboNameList[i], class'Class'));
        else
            xPlayer(Controller).ComboList[i] = None;
    }

    xPlayer(Controller).ComboNameList[0] = string(class'RPGComboSpeed');
    xPlayer(Controller).ComboList[0] = class'RPGComboSpeed';
    xPlayer(Controller).ComboNameList[1] = string(class'RPGComboBerserk');
    xPlayer(Controller).ComboList[1] = class'RPGComboBerserk';
    xPlayer(Controller).ComboNameList[2] = string(class'RPGComboDefensive');
    xPlayer(Controller).ComboList[2] = class'RPGComboDefensive';
    xPlayer(Controller).ComboNameList[3] = string(class'RPGComboInvis');
    xPlayer(Controller).ComboList[3] = class'RPGComboInvis';
}

simulated final function ModifyCombos()
{
    local int i;

    for(i = 0; i < Abilities.Length; i++)
        if(Abilities[i].ComboReplacements.Length > 0)
            Abilities[i].ReplaceCombos(xPlayer(Controller));
}

simulated function int FindOrderEntry(class<RPGArtifact> AClass)
{
    local int i;

    for(i = 0; i < ArtifactOrder.Length; i++)
    {
        if(ArtifactOrder[i].ArtifactClass == AClass)
            return i;
    }
    return -1;
}

function ServerSortArtifacts()
{
    local Inventory Inv;
    local RPGArtifact A;
    local array<RPGArtifact> CurrentArtifacts;
    local int i;

    if(Controller.Pawn != None)
    {
        //strip out all artifacts
        Inv = Controller.Pawn.Inventory;
        while(Inv != None)
        {
            if(RPGArtifact(Inv) != None)
            {
                A = RPGArtifact(Inv);
                CurrentArtifacts[CurrentArtifacts.Length] = A;

                Inv = A.Inventory;

                A.StripOut();
            }
            else
            {
                Inv = Inv.Inventory;
            }
        }

        //sort them back in
        for(i = 0; i < CurrentArtifacts.Length; i++)
            CurrentArtifacts[i].SortIn();
    }
}

function ServerClearArtifactOrder()
{
    ArtifactOrder.Length = 0;
}

function ServerAddArtifactOrderEntry(ArtifactOrderStruct OrderEntry)
{
    local int i;
    local Inventory Inv;

    //find if already in the list
    for(i = 0; i < ArtifactOrder.Length; i++)
    {
        if(ArtifactOrder[i].ArtifactClass == OrderEntry.ArtifactClass)
            break;
    }

    if(Controller.Pawn != None)
    {
        Inv = Controller.Pawn.FindInventoryType(OrderEntry.ArtifactClass);

        if(Inv != None)
            Powerups(Inv).bActivatable = !OrderEntry.bNeverShow;
    }

    //i was set in for loop above
    ArtifactOrder[i] = OrderEntry;
}

simulated function ResendArtifactOrder()
{
    local int i;

    ServerClearArtifactOrder();
    for(i = 0; i < ArtifactOrder.Length; i++)
        ServerAddArtifactOrderEntry(ArtifactOrder[i]);

    ServerSortArtifacts();
}

function SaveCooldown(RPGArtifact A)
{
    local float TimeLeft;
    local ArtifactCooldown Cooldown;
    local int i;

    if(A.NextUseTime > Level.TimeSeconds)
    {
        TimeLeft = A.NextUseTime - Level.TimeSeconds;

        for(i = 0; i < SavedCooldown.Length; i++)
        {
            if(A.class == SavedCooldown[i].AClass)
            {
                SavedCooldown[i].TimeLeft = TimeLeft;
                return;
            }
        }

        Cooldown.AClass = A.class;
        Cooldown.TimeLeft = TimeLeft;
        SavedCooldown[SavedCooldown.Length] = Cooldown;
    }
}

function int GetSavedCooldown(class<RPGArtifact> AClass)
{
    local int i;

    for(i = 0; i < SavedCooldown.Length; i++)
    {
        if(AClass == SavedCooldown[i].AClass)
            return i;
    }

    return -1;
}

function ModifyArtifact(RPGArtifact A)
{
    local int i;

    ClientCheckArtifactClass(A.class);

    //Allow abilities to modify
    for(i = 0; i < Abilities.Length; i++)
    {
        if(Abilities[i].bAllowed)
            Abilities[i].ModifyArtifact(A);
    }

    //Apply saved cooldown
    i = GetSavedCooldown(A.class);
    if(i >= 0)
    {
        A.ForceCooldown(SavedCooldown[i].TimeLeft);
        SavedCooldown.Remove(i, 1);
    }

    /*
        If bNeverShow setting is used, make it non-selectable
        bActivatable is unused by the artifact itself, but Powerups / PlayerController
        use it to determine whether an item can be selected using NextItem and PrevItem
    */
    i = FindOrderEntry(A.class);
    A.bActivatable = !(i >= 0 && ArtifactOrder[i].bNeverShow);
}

simulated function ClientCheckArtifactClass(class<RPGArtifact> AClass)
{
    local ArtifactOrderStruct OrderEntry;

    //make sure that this artifact class gets listed in the order so the interaction shows it
    if(FindOrderEntry(AClass) == -1)
    {
        OrderEntry.ArtifactClass = AClass;
        OrderEntry.ArtifactID = AClass.default.ArtifactID;
        OrderEntry.bShowAlways = false;
        OrderEntry.bNeverShow = false;

        ArtifactOrder[ArtifactOrder.Length] = OrderEntry;
        ServerAddArtifactOrderEntry(OrderEntry);
        ServerSortArtifacts();
    }
}

simulated function ReceiveAbility(RPGAbility Ability)
{
    local int i;

    Ability.SetOwner(Controller);

    if(class'Util'.static.InArray(Ability, AllAbilities) == -1)
    {
        AbilitiesReceived++;
        AllAbilities[Ability.Index] = Ability;

        if(Ability.AbilityLevel > 0)
        {
            for(i = 0; i < Abilities.Length; i++)
            {
                if(Abilities[i].BuyOrderIndex > Ability.BuyOrderIndex)
                    break;
            }
            Abilities.Insert(i, 1);
            Abilities[i] = Ability;
        }
    }
    else
    {
        Warn("Received ability" @ Ability @ "twice!");
    }

    if(AbilitiesReceived == AbilitiesTotal)
    {
        ClientEnableRPGMenu();
        ModifyCombos();
    }
}

simulated function CheckPlayerViewShake()
{
    local float ShakeScaling;

    if(PlayerController(Controller) != None)
    {
        ShakeScaling = VSize(PlayerController(Controller).ShakeRotMax) / 7500.0f;
        if(ShakeScaling > 1.0f)
        {
            PlayerController(Controller).ShakeRotMax /= ShakeScaling;
            PlayerController(Controller).ShakeRotTime /= ShakeScaling;
            PlayerController(Controller).ShakeOffsetMax /= ShakeScaling;
        }
    }
}

simulated event Tick(float dt)
{
    local Weapon W;
    local RPGWeaponModifier WM;
    local bool bWasActive;
    local Inventory Inv;
    local int x;

    if(Level.NetMode != NM_DedicatedServer)
    {
        if(!bClientSetup)
            ClientSetup();

        if(SwitchToWeapon != None) //wait until it arrived in the inventory?
        {
            if(Controller.Pawn != None)
            {
                for(Inv = Controller.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
                {
                    if(Inv == SwitchToWeapon)
                    {
                        PerformWeaponSwitch(SwitchToWeapon);
                        SwitchToWeapon = None;
                        break;
                    }
                }
            }
        }

        //Tick status icons
        for(x = 0; x < Status.Length; x++) {
            if(Status[x].bShouldTick)
                Status[x].Tick(dt);
        }
    }

    if(Controller == None)
    {
        Destroy();
        return;
    }

    CheckPlayerViewShake();

    if(Role < ROLE_Authority) {
        ProcessProjectileMods();
    }

    if(Role == ROLE_Authority)
    {
        //Check weapon
        if(Controller.Pawn != None && Vehicle(Controller.Pawn) == None)
        {
            W = Controller.Pawn.Weapon;
            if(W != LastPawnWeapon)
            {
                if(W != None)
                {
                    if(TransLauncher(W) != None && W.OldWeapon == None && LastPawnWeapon != None) {
                        //Log("Force set old weapon on translocator:" @ LastPawnWeapon);
                        W.OldWeapon = LastPawnWeapon;
                    }

                    //Maybe stop weapon modifier
                    WM = class'RPGWeaponModifier'.static.GetFor(W);
                    if(WM != None && WM.bActive) {
                        //Log("Restarting weapon modifier for" @ W);
                        bWasActive = true;
                        WM.StopEffect();
                    }

                    //Apply modifiers
                    for(x = 0; x < Abilities.Length; x++)
                    {
                        if(Abilities[x].bAllowed)
                            Abilities[x].ModifyWeapon(W);
                    }

                    //Restart weapon modifier
                    if(WM != None && bWasActive) {
                        WM.StartEffect();
                    }
                }

                LastPawnWeapon = W;
                if(LastPawnWeapon != None) {
                    LastSelectedWeapon.WeaponClass = LastPawnWeapon.class;

                    WM = class'RPGWeaponModifier'.static.GetFor(LastPawnWeapon);
                    if(WM != None) {
                        LastSelectedWeapon.ModifierClass = WM.class;
                    } else {
                        LastSelectedWeapon.ModifierClass = None;
                    }
                }
            }
        }
        else if(Controller.Pawn == None)
        {
            LastPawnWeapon = None;
        }

        if(Controller.Pawn != None && Controller.Pawn.Health <= 0)
        {
            if(Monsters.Length > 0 && bMonstersDie)
                ServerKillMonsters();
            if(Buildings.Length > 0 && bBuildingsDie)
                ServerDestroyBuildings();
            if(Sentinels.Length > 0 && bSentinelsDie)
                ServerDestroySentinels();
            if(Turrets.Length > 0 && bTurretsDie)
                ServerDestroyTurrets();
            if(Vehicles.Length > 0 && bVehiclesDie)
                ServerDestroyVehicles();
            if(Utilities.Length > 0 && bUtilitiesDie)
                ServerDestroyUtilities();
        }

        //Clean monsters
        x = 0;
        while(x < Monsters.Length)
        {
            if(Monsters[x].Pawn == None || Monsters[x].Pawn.Health <= 0)
            {
                NumMonsters--;
                MonsterPoints += Monsters[x].Points;
                Monsters.Remove(x, 1);
            }
            else
                x++;
        }

        //Clean buildings
        x = 0;
        while(x < Buildings.Length)
        {
            if(Buildings[x].Pawn == None || Buildings[x].Pawn.Health <= 0)
            {
                NumBuildings--;
                BuildingPoints += Buildings[x].Points;
                Buildings.Remove(x, 1);
            }
            else
                x++;
        }

        //Clean sentinels
        x = 0;
        while(x < Sentinels.Length)
        {
            if(Sentinels[x].Pawn == None || Sentinels[x].Pawn.Health <= 0)
            {
                NumSentinels--;
                SentinelPoints += Sentinels[x].Points;
                Sentinels.Remove(x, 1);
            }
            else
                x++;
        }

        //Clean turrets
        x = 0;
        while(x < Turrets.Length)
        {
            if(Turrets[x].Pawn == None || Turrets[x].Pawn.Health <= 0)
            {
                NumTurrets--;
                TurretPoints += Turrets[x].Points;
                Turrets.Remove(x, 1);
            }
            else
                x++;
        }

        //Clean vehicles
        x = 0;
        while(x < Vehicles.Length)
        {
            if(Vehicles[x].Pawn == None || Vehicles[x].Pawn.Health <= 0)
            {
                NumVehicles--;
                VehiclePoints += Vehicles[x].Points;
                Vehicles.Remove(x, 1);
            }
            else
                x++;
        }

        //Clean utilities
        x = 0;
        while(x < Utilities.Length)
        {
            if(Utilities[x].Pawn == None || Utilities[x].Pawn.Health <= 0)
            {
                NumUtilities--;
                UtilityPoints += Utilities[x].Points;
                Utilities.Remove(x, 1);
            }
            else
                x++;
        }

        //Clean locked vehicles
        x = 0;
        while(x < LockedVehicles.Length)
        {
            if(LockedVehicles[x] == None || LockedVehicles[x].Health <= 0)
                LockedVehicles.Remove(x , 1);
            else
                x++;
        }

        //Award experience for daredevil points
        if(
            class'RPGRules'.default.EXP_Daredevil != 0 &&
            TeamPlayerReplicationInfo(PRI) != None &&
            TeamPlayerReplicationInfo(PRI).DaredevilPoints > DaredevilPoints
        )
        {
            x = TeamPlayerReplicationInfo(PRI).DaredevilPoints - DaredevilPoints;
            //Log(RPGName @ "gained" @ x @ "daredevil points!");

            DaredevilPoints += x;
            AwardExperience(float(x) * class'RPGRules'.default.EXP_Daredevil);
        }
    }
}

function Timer()
{
    local int ValidHealers;
    local Controller C;

    if(Vehicle(Controller.Pawn) == None)
    {
        SetTimer(0.0, false);
        return;
    }

    // keep a list of who is healing
    VehicleHealers.Length = 0;
    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if((C.Pawn != None && C.Pawn.Weapon != None && LinkFire(C.Pawn.Weapon.GetFireMode(1)) != None
        && LinkFire(C.Pawn.Weapon.GetFireMode(1)).LockedPawn == class'Util'.static.GetRootVehicle(Vehicle(Controller.Pawn))
        && WeaponModifier_EngineerLink(class'WeaponModifier_EngineerLink'.static.GetFor(C.Pawn.Weapon)) != None)
        || (RPGLinkSentinelController(C) != None && RPGLinkSentinelController(C).HealingVehicle == class'Util'.static.GetRootVehicle(Vehicle(Controller.Pawn))))
        {
            VehicleHealers[VehicleHealers.Length] = C;
            ValidHealers++;
        }
    }

    if(ValidHealers > 0 && Controller.Pawn.Health < Controller.Pawn.HealthMax)
    {
        // healed turret of health, so no damage/xp bonus this second
        LastVehicleHealTime = Level.TimeSeconds;
    }

    // now update the replicated value
    if(NumVehicleHealers != ValidHealers)
        NumVehicleHealers = ValidHealers;
}

function ServerNoteActivity()
{
    if(PlayerController(Controller) != None)
        PlayerController(Controller).LastActiveTime = Level.TimeSeconds;
}

simulated function ClientReInitMenu()
{
    if(Menu != None)
        Menu.InitFor(Self);
}

function AwardExperience(float exp)
{
    local FX_LevelUp Effect;
    local int Count;

    if(exp == 0)
        return;

    if(bGameEnded)
        return;

    if(PlayerController(Controller) != None && Level.Game.NumPlayers < class'MutTURRPG'.default.MinHumanPlayersForExp)
        return;

    if(RPGMut.GameSettings.ExpScale > 0.0)
        exp *= RPGMut.GameSettings.ExpScale; //scale xp gain

    Experience = FMax(0.0, Experience + exp);
    ClientNotifyExpGain(exp);

    if(!RPGMut.bLevelCap || RPGLevel < RPGMut.Levels.Length) //don't allow levelup when max level was reached
    {
        while(Experience >= NeededExp && Count < 10000)
        {
            Count++;

            RPGLevel++;
            if(RPGLevel % RPGMut.StatPointsIncrement == 0)
                StatPointsAvailable += RPGMut.StatPointsPerIncrement;
            if(RPGLevel % RPGMut.AbilityPointsIncrement == 0)
                AbilityPointsAvailable += RPGMut.AbilityPointsPerIncrement;
            Experience -= float(NeededExp);
            NeededExp = RPGMut.GetRequiredXpForLevel(RPGLevel);

            if(Count <= RPGMut.MaxLevelupEffectStacking && Controller != None && Controller.Pawn != None)
            {
                Effect = Controller.Pawn.spawn(class'FX_LevelUp', Controller.Pawn);
                Effect.SetDrawScale(Controller.Pawn.CollisionRadius / Effect.CollisionRadius);
                Effect.Initialize();
            }
        }

        if(Count > 0)
        {
            if(Controller != None && Controller.Pawn != None) {
                Controller.Pawn.PlaySound(LevelUpSound, SLOT_Interact, 1.0,, 1024);
            }

            Level.Game.BroadCastLocalized(Self, class'LocalMessage_LevelUp', RPGLevel, PRI);
            ClientShowHint(LevelUpText);

            if(AIBuild != None)
                AIBuild.Build(Self);

            PlayerLevel.RPGLevel = RPGLevel;
            PlayerLevel.ExpNeeded = NeededExp;
        }
    }

    PlayerLevel.Experience = Experience;
}

simulated function ClientNotifyExpGain(float Amount)
{
    if(Interaction != None)
        Interaction.NotifyExpGain(Amount);
}

simulated function ClientShowHint(string Hint)
{
    if(Interaction != None)
        Interaction.ShowHint(Hint);
}

simulated function ClientEnableRPGMenu()
{
    local int i;

    for(i = 0; i < AllAbilities.Length; i++)
    {
        if(AllAbilities[i].bIsStat)
        {
            class'RPGMenu'.default.bStats = true;
            break;
        }
    }

    bClientSyncDone = true;
    if(Interaction != None)
    {
        Interaction.bMenuEnabled = true;
        Interaction.ShowHint(IntroText);
    }
}

simulated function int HasAbility(class<RPGAbility> AbilityClass, optional bool bIgnoreIfNotAllowed)
{
    local int x;

    for(x = 0; x < Abilities.Length; x++)
    {
        if(Abilities[x].class == AbilityClass) {
            if(Abilities[x].bAllowed || bIgnoreIfNotAllowed) {
                return Abilities[x].AbilityLevel;
            } else {
                return 0;
            }
        }
    }
    return 0;
}

simulated function RPGAbility GetOwnedAbility(class<RPGAbility> AbilityClass)
{
    local int x;

    for(x = 0; x < Abilities.Length; x++)
    {
        if(Abilities[x].class == AbilityClass) {
            if(Abilities[x].bAllowed) {
                return Abilities[x];
            } else {
                return None;
            }
        }
    }
    return None;
}

simulated function RPGAbility GetAbility(class<RPGAbility> AbilityClass)
{
    local int x;

    for(x = 0; x < AllAbilities.Length; x++)
    {
        if(AllAbilities[x].class == AbilityClass)
            return AllAbilities[x];
    }
    return None;
}

function bool ServerBuyAbility(RPGAbility Ability, optional int Amount)
{
    if(Ability.Buy(Amount))
    {
        ModifyStats();
        return true;
    }
    else
    {
        return false;
    }
}

function AddThrownWeapon(class<Weapon> WeaponClass) {
    if(!HasThrownWeapon(WeaponClass)) {
        ThrownWeapons[ThrownWeapons.Length] = WeaponClass;
    }
}

function RemoveThrownWeapon(class<Weapon> WeaponClass) {
    local int i;

    for(i = 0; i < ThrownWeapons.Length; i++) {
        if(ThrownWeapons[i] == WeaponClass) {
            ThrownWeapons.Remove(i, 1);
            return;
        }
    }
}

function bool HasThrownWeapon(class<Weapon> WeaponClass) {
    local int i;

    for(i = 0; i < ThrownWeapons.Length; i++) {
        if(ThrownWeapons[i] == WeaponClass) {
            return true;
        }
    }
    return false;
}

function AnnounceMyRole() {
    local Controller C;

    if(RPGBot(Controller) != None) {
        for(C = Level.ControllerList; C != None; C = C.NextController) {
            if(C.SameTeamAs(Controller) && PlayerController(C) != None) {
                RPGBot(Controller).AnnounceRole(PlayerController(C));
            }
        }
    }
}

function AnnounceBotRoles() {
    local Controller C;

    if(PlayerController(Controller) != None) {
        for(C = Level.ControllerList; C != None; C = C.NextController) {
            if(C.SameTeamAs(Controller) && RPGBot(C) != None) {
                RPGBot(C).AnnounceRole(PlayerController(Controller));
            }
        }
    }
}

function ModifyPlayer(Pawn Other)
{
    local Inventory Inv;
    local int i;

    if(Level.Game.bTeamGame)
        Team = PRI.Team.TeamIndex;

    //must be emptied to avoid lifetime PDP "protection"...
    ThrownWeapons.Length = 0;

    if(Other != Controller.Pawn)
    {
        Log("RPGReplicationInfo was told to modify a Pawn that doesn't belong to this RPRI's Controller! Pawn is " $
            Other.GetHumanReadableName() $ ", RPRI belongs to " $ PRI.PlayerName, 'TURRPG');

        return;
    }

    //Call abilities
    for(i = 0; i < Abilities.Length; i++)
    {
        if(Abilities[i].bAllowed)
            Abilities[i].ModifyPawn(Other);
    }

    ProcessGrantQueue(); //give weapons

    //Restore last selected weapon
    if(LastSelectedWeapon.WeaponClass != None)
    {
        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(
                Inv.class == LastSelectedWeapon.WeaponClass &&
                (LastSelectedWeapon.ModifierClass == None || LastSelectedWeapon.ModifierClass.static.GetFor(Weapon(Inv)) != None)
            )
            {
                ClientSwitchToWeapon(Weapon(Inv));
                break;
            }
        }
    }

    if(bTeamChanged)
    {
        //respawning after team switch
        AnnounceBotRoles();
    }
    bTeamChanged = false;

    //Restore last selected artifact
    if(LastSelectedPowerupType != None)
    {
        Inv = Other.FindInventoryType(LastSelectedPowerupType);
        if(Inv != None)
            Other.SelectedItem = Powerups(Inv);
    }

    if(Other.SelectedItem == None) //if not possible, do this
        Other.NextItem();
}

function AddMonster(Monster M, optional int Points) {
    local int i;

    i = Monsters.Length;
    Monsters.Length = i + 1;
    Monsters[i].Pawn = M;
    Monsters[i].Points = Points;

    ModifyMonster(M);
}

function ModifyMonster(Monster M) {
    local int i;

    //let stats do their stuff first
    for(i = 0; i < Abilities.Length; i++)
        if(Abilities[i].bAllowed && Abilities[i].bIsStat)
            Abilities[i].ModifyMonster(M, Controller.Pawn);

    //then abilities
    for(i = 0; i < Abilities.Length; i++)
        if(Abilities[i].bAllowed && !Abilities[i].bIsStat)
            Abilities[i].ModifyMonster(M, Controller.Pawn);
}

function ServerKillMonsters()
{
    while(Monsters.Length > 0)
    {
        if(Monsters[0].Pawn != None)
            Monsters[0].Pawn.Destroy();

        Monsters.Remove(0, 1);
    }
    NumMonsters = 0;
    MonsterPoints = MaxMonsterPoints;
}

final function ServerDestroyBuildings()
{
    while(Buildings.Length > 0)
    {
        if(Vehicle(Buildings[0].Pawn) != None)
        {
            class'Util'.static.EjectAllDrivers(Vehicle(Buildings[0].Pawn));
            if(Buildings[0].Pawn.Controller != None && PlayerController(Buildings[0].Pawn.Controller) == None)
                Buildings[0].Pawn.Controller.Destroy();
        }
        if(Buildings[0].Pawn != None)
            Buildings[0].Pawn.Destroy();
        Buildings.Remove(0, 1);
    }
    NumBuildings = 0;
    BuildingPoints = MaxBuildingPoints;
}

final function ServerDestroySentinels()
{
    while(Sentinels.Length > 0)
    {
        if(Vehicle(Sentinels[0].Pawn) != None)
        {
            class'Util'.static.EjectAllDrivers(Vehicle(Sentinels[0].Pawn));
            if(Sentinels[0].Pawn.Controller != None && PlayerController(Sentinels[0].Pawn.Controller) == None)
                Sentinels[0].Pawn.Controller.Destroy();
        }
        if(Sentinels[0].Pawn != None)
            Sentinels[0].Pawn.Destroy();
        Sentinels.Remove(0, 1);
    }
    NumSentinels = 0;
    SentinelPoints = MaxSentinelPoints;
}

final function ServerDestroyTurrets()
{
    while(Turrets.Length > 0)
    {
        if(Vehicle(Turrets[0].Pawn) != None)
        {
            class'Util'.static.EjectAllDrivers(Vehicle(Turrets[0].Pawn));
            if(Turrets[0].Pawn.Controller != None && PlayerController(Turrets[0].Pawn.Controller) == None)
                Turrets[0].Pawn.Controller.Destroy();
        }
        if(Turrets[0].Pawn != None)
            Turrets[0].Pawn.Destroy();
        Turrets.Remove(0, 1);
    }
    NumTurrets = 0;
    TurretPoints = MaxTurretPoints;
}

final function ServerDestroyVehicles()
{
    while(Vehicles.Length > 0)
    {
        if(Vehicle(Vehicles[0].Pawn) != None)
        {
            class'Util'.static.EjectAllDrivers(Vehicle(Vehicles[0].Pawn));
            if(Vehicles[0].Pawn.Controller != None && PlayerController(Vehicles[0].Pawn.Controller) == None)
                Vehicles[0].Pawn.Controller.Destroy();
        }
        if(Vehicles[0].Pawn != None)
            Vehicles[0].Pawn.Destroy();
        Vehicles.Remove(0, 1);
    }
    NumVehicles = 0;
    VehiclePoints = MaxVehiclePoints;
}

final function ServerDestroyUtilities()
{
    while(Utilities.Length > 0)
    {
        if(Vehicle(Utilities[0].Pawn) != None)
        {
            class'Util'.static.EjectAllDrivers(Vehicle(Utilities[0].Pawn));
            if(Utilities[0].Pawn.Controller != None && PlayerController(Utilities[0].Pawn.Controller) == None)
                Utilities[0].Pawn.Controller.Destroy();
        }
        if(Utilities[0].Pawn != None)
            Utilities[0].Pawn.Destroy();
        Utilities.Remove(0, 1);
    }
    NumUtilities = 0;
    UtilityPoints = MaxUtilityPoints;
}

final function AddConstruction(string ConstructionType, Pawn P, int Points)
{
    local int i;

    switch(ConstructionType)
    {
        case "BUILDING":
            i = Buildings.Length;
            Buildings.Length = i + 1;
            Buildings[i].Pawn = P;
            Buildings[i].Points = Points;
            BuildingPoints -= Points;
            NumBuildings++;
            break;
        case "SENTINEL":
            i = Sentinels.Length;
            Sentinels.Length=i+1;
            Sentinels[i].Pawn=P;
            Sentinels[i].Points=Points;
            SentinelPoints-=Points;
            NumSentinels++;
            break;
        case "TURRET":
            i = Turrets.Length;
            Turrets.Length = i + 1;
            Turrets[i].Pawn = P;
            Turrets[i].Points = Points;
            TurretPoints -= Points;
            NumTurrets++;
            break;
        case "VEHICLE":
            i = Vehicles.Length;
            Vehicles.Length = i + 1;
            Vehicles[i].Pawn = P;
            Vehicles[i].Points = Points;
            VehiclePoints -= Points;
            NumVehicles++;
            break;
        case "UTILITY":
            i = Utilities.Length;
            Utilities.Length = i + 1;
            Utilities[i].Pawn = P;
            Utilities[i].Points = Points;
            UtilityPoints -= Points;
            NumUtilities++;
            break;
    }

    // lets set the eject to be false. If you have the correct skill later, it can reset
    if(Vehicle(P) != None)
        Vehicle(P).bEjectDriver = false;
    if (P.SuperHealthMax == 199)
        P.SuperHealthMax = 200; // to show it is a summoned item

    //let stats do their stuff first
    for(i = 0; i < Abilities.Length; i++)
    {
        if(Abilities[i].bAllowed && Abilities[i].bIsStat)
            Abilities[i].ModifyConstruction(P);
    }

    //then abilities
    for(i = 0; i < Abilities.Length; i++)
    {
        if(Abilities[i].bAllowed && !Abilities[i].bIsStat)
            Abilities[i].ModifyConstruction(P);
    }
}

final function bool LockVehicle(Vehicle V)
{
    local int i;

    if(class'Util'.static.InArray(V, LockedVehicles) != -1)
        return false;

    for(i = 0; i < Buildings.Length; i++)
    {
        if(Buildings[i].Pawn == V)
        {
            LockedVehicles[LockedVehicles.Length] = V;
            V.SetOverlayMaterial(LockedVehicleOverlay, 50000.0, false);
            return true;
        }
    }
    for(i = 0; i < Sentinels.Length; i++)
    {
        if(Sentinels[i].Pawn == V)
        {
            LockedVehicles[LockedVehicles.Length] = V;
            V.SetOverlayMaterial(LockedVehicleOverlay, 50000.0, false);
            return true;
        }
    }
    for(i = 0; i < Turrets.Length; i++)
    {
        if(Turrets[i].Pawn == V)
        {
            LockedVehicles[LockedVehicles.Length] = V;
            V.SetOverlayMaterial(LockedVehicleOverlay, 50000.0, false);
            return true;
        }
    }
    for(i = 0; i < Vehicles.Length; i++)
    {
        if(Vehicles[i].Pawn == V)
        {
            LockedVehicles[LockedVehicles.Length] = V;
            V.SetOverlayMaterial(LockedVehicleOverlay, 50000.0, false);
            return true;
        }
    }
    for(i = 0; i < Utilities.Length; i++)
    {
        if(Utilities[i].Pawn == V)
        {
            LockedVehicles[LockedVehicles.Length] = V;
            V.SetOverlayMaterial(LockedVehicleOverlay, 50000.0, false);
            return true;
        }
    }

    return false;
}

final function bool UnlockVehicle(Vehicle V)
{
    local int i;

    i = class'Util'.static.InArray(V, LockedVehicles);
    if(i > -1)
    {
        LockedVehicles.Remove(i, 1);
        V.SetOverlayMaterial(LockedVehicleOverlay, 0.0, false);
        return true;
    }
}

simulated function ClientSetName(string NewName)
{
    if(PlayerController(Controller) != None)
        PlayerController(Controller).SetName(NewName);
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
    local int i;

    for(i = 0; i < Abilities.length; i++)
    {
        if(Abilities[i].bAllowed)
            Abilities[i].ModifyVehicle(V);
    }

    VehicleHealers.Length = 0;
    NumVehicleHealers = 0;
    SetTimer(0.5, true); //for calculating number of healers
}

function DriverLeftVehicle(Vehicle V, Pawn P)
{
    local int i;

    for(i = 0; i < Abilities.Length; i++)
    {
        if(Abilities[i].bAllowed)
            Abilities[i].UnModifyVehicle(V);
    }

    VehicleHealers.Length = 0;
    NumVehicleHealers = 0;
    SetTimer(0.0, true); //stop calculating number of healers
}

function ServerSwitchBuild(string NewBuild)
{
    Log(RPGName $ " switches build to " $ NewBuild, 'TURRPG2');
    RPGMut.SwitchBuild(Self, NewBuild);

    ServerKillMonsters();
    ServerDestroyBuildings();
    ServerDestroySentinels();
    ServerDestroyTurrets();
    ServerDestroyVehicles();
    ServerDestroyUtilities();
}

function GameEnded()
{
    bGameEnded = true;
    ClientGameEnded();
}

simulated function ClientGameEnded()
{
    //anything to do?
}

function ServerResetData()
{
    local string OwnerID;

    Log(PRI.PlayerName $ " - RESET!", 'TURRPG2');

    Reset();

    OwnerID = DataObject.ID;

    DataObject.ClearConfig();
    DataObject = new(None, string(DataObject.Name)) class'RPGData';

    DataObject.ID = OwnerID;
    DataObject.LV = RPGMut.StartingLevel;
    DataObject.SPA = RPGMut.StartingStatPoints + (Ceil(float(DataObject.LV + 1) / RPGMut.StatPointsIncrement) - 1) * RPGMut.StatPointsPerIncrement;
    DataObject.APA = RPGMut.StartingAbilityPoints + (Ceil(float(DataObject.LV + 1) / RPGMut.AbilityPointsIncrement) - 1) * RPGMut.AbilityPointsPerIncrement;
    DataObject.XN = RPGMut.GetRequiredXpForLevel(DataObject.LV);

    DataObject.AA = 0;
    DataObject.AI = "";

    DataObject.SaveConfig();

    Level.Game.BroadCastLocalized(Self, class'LocalMessage_Reset', 0, PRI);
    Level.Game.BroadCastLocalized(Self, class'LocalMessage_LevelUp', RPGMut.StartingLevel, PRI);

    Controller.Adrenaline = 0;
    if(Controller.Pawn != None)
        Controller.Pawn.Suicide();

    Destroy();
}

function ServerRebuildData()
{
    local float CostLeft;
    local int LevelLoss;

    if(bAllowRebuild)
    {
        Log(PRI.PlayerName $ " - REBUILD!", 'TURRPG2');

        Reset();

        DataObject.AB.Length = 0;
        DataObject.AL.Length = 0;

        CostLeft = float(RPGMut.RebuildCost);
        while(DataObject.XP < CostLeft && DataObject.LV > RPGMut.StartingLevel && LevelLoss < RPGMut.RebuildMaxLevelLoss)
        {
            CostLeft -= DataObject.XP;

            DataObject.LV--;
            DataObject.XP = RPGMut.GetRequiredXpForLevel(DataObject.LV);

            LevelLoss++;
        }
        DataObject.XP = FMax(0.0f, DataObject.XP - CostLeft);

        DataObject.SPA = RPGMut.StartingStatPoints + (Ceil(float(DataObject.LV + 1) / RPGMut.StatPointsIncrement) - 1) * RPGMut.StatPointsPerIncrement;
        DataObject.APA = RPGMut.StartingAbilityPoints + (Ceil(float(DataObject.LV + 1) / RPGMut.AbilityPointsIncrement) - 1) * RPGMut.AbilityPointsPerIncrement;
        DataObject.XN = RPGMut.GetRequiredXpForLevel(DataObject.LV);

        DataObject.SaveConfig();

        Level.Game.BroadCastLocalized(Self, class'LocalMessage_Rebuild', 0, PRI);
        if(LevelLoss > 0)
            Level.Game.BroadCastLocalized(Self, class'LocalMessage_LevelUp', DataObject.LV, PRI);

        Controller.Adrenaline = 0;
        if(Controller.Pawn != None)
            Controller.Pawn.Suicide();

        Destroy();
    }
}

function SetLevel(int NewLevel)
{
    Log(PRI.PlayerName $ " - SETLEVEL" @ NewLevel $ "!", 'TURRPG2');

    DataObject.LV = NewLevel;
    DataObject.SPA = RPGMut.StartingStatPoints + (Ceil(float(DataObject.LV + 1) / RPGMut.StatPointsIncrement) - 1) * RPGMut.StatPointsPerIncrement;
    DataObject.APA = RPGMut.StartingAbilityPoints + (Ceil(float(DataObject.LV + 1) / RPGMut.AbilityPointsIncrement) - 1) * RPGMut.AbilityPointsPerIncrement;
    DataObject.XN = RPGMut.GetRequiredXpForLevel(NewLevel);
    DataObject.XP = 0;
    DataObject.AB.Length = 0;
    DataObject.AL.Length = 0;
    DataObject.SaveConfig();

    Level.Game.BroadCastLocalized(Self, class'LocalMessage_LevelUp', NewLevel, PRI);

    Controller.Adrenaline = 0;
    if(Controller.Pawn != None)
        Controller.Pawn.Suicide();

    Destroy();
}

function ServerActivateArtifact(string ArtifactID)
{
    local Inventory Inv;

    if(Controller.Pawn != None)
    {
        for(Inv = Controller.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(RPGArtifact(Inv) != None &&
                RPGArtifact(Inv).ArtifactID ~= ArtifactID)
            {
                RPGArtifact(Inv).Activate();
                break;
            }
        }
    }
}

function ServerGetArtifact(string ArtifactID)
{
    local Inventory Inv;

    if(Controller.Pawn != None)
    {
        if(
            RPGArtifact(Controller.Pawn.SelectedItem) != None &&
            RPGArtifact(Controller.Pawn.SelectedItem).ArtifactID ~= ArtifactID)
        {
            return;
        }

        for(Inv = Controller.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(RPGArtifact(Inv) != None &&
                RPGArtifact(Inv).ArtifactID ~= ArtifactID)
            {
                Controller.Pawn.SelectedItem = Powerups(Inv);
                break;
            }
        }
    }
}

simulated function PerformWeaponSwitch(Weapon W)
{
    local Pawn Pawn;

    Pawn = Controller.Pawn;
    if(Pawn != None && Vehicle(Pawn) == None)
    {
        if(W == None)
        {
            Log("Failed to switch weapon on client side - Weapon is NONE.", 'TURRPG2');
            return;
        }

        if(Pawn.PendingWeapon != None && Pawn.PendingWeapon.bForceSwitch)
            return;

        if(Pawn.Weapon == None)
        {
            Pawn.PendingWeapon = W;
            Pawn.ChangedWeapon();
        }
        else if(Pawn.Weapon != W || Pawn.PendingWeapon != None)
        {
            Pawn.PendingWeapon = W;
            Pawn.Weapon.PutDown();
        }
        else if(Pawn.Weapon == W)
        {
            Pawn.Weapon.Reselect();
        }
    }
}

simulated function ClientSwitchToWeapon(Weapon W)
{
    SwitchToWeapon = W;
}

function PickAIBuild()
{
    local array<string> List;

    if(AIBuild != None || AIController(Controller) == None)
        return;

    if(DataObject.AI == "")
    {
        List = class'RPGData'.static.GetPerObjectNames("TURRPGAI", string(class'RPGAIBuild'.name));
        if(List.Length > 0)
        {
            DataObject.AI = List[Rand(List.Length)];
            DataObject.AA = 0;

            Log(PRI.PlayerName @ "has picked the AIBuild \"" $ DataObject.AI $ "\".", 'TURRPG2');
        }
        else
        {
            Warn("There are no AIBuilds defined!");
            return;
        }
    }

    if(DataObject.AI != "")
    {
        AIBuild = new(None, DataObject.AI) class'RPGAIBuild';
        AIBuildAction = DataObject.AA;
    }
}

function LoadData(RPGData Data)
{
    local RPGAbility Ability;
    local int x, BuyOrderIndex;

    DataObject = Data;
    RPGName = string(Data.Name);

    RPGLevel = DataObject.LV;
    StatPointsAvailable = DataObject.SPA;
    AbilityPointsAvailable = DataObject.APA;
    Experience = DataObject.XP;
    NeededExp = DataObject.XN;

    Abilities.Remove(0, Abilities.Length);

    for(x = 0; x < DataObject.AB.Length; x++)
    {
        Ability = GetAbility(RPGMut.ResolveAbility(DataObject.AB[x]));
        if(Ability != None)
        {
            Ability.AbilityLevel = DataObject.AL[x];
            Ability.BuyOrderIndex = BuyOrderIndex++;
            Abilities[Abilities.Length] = Ability;
        }
        else
        {
            Warn("Could not find ability \"" $ DataObject.AB[x] $ "\"");
        }
    }

    ModifyStats();
    PickAIBuild();
}

function SaveData()
{
    local int x;

    if(bImposter)
        return;

    Log(RPGName @ "SaveData");

    DataObject.LV = RPGLevel;
    DataObject.SPA = StatPointsAvailable;
    DataObject.APA = AbilityPointsAvailable;
    DataObject.XP = Experience;
    DataObject.XN = NeededExp;

    DataObject.AB.Remove(0, DataObject.AB.Length);
    DataObject.AL.Remove(0, DataObject.AL.Length);

    for(x = 0; x < Abilities.Length; x++)
    {
        DataObject.AB[x] = RPGMut.GetAbilityAlias(Abilities[x].class);
        DataObject.AL[x] = Abilities[x].AbilityLevel;
    }

    DataObject.AA = AIBuildAction;
    DataObject.SaveConfig();
}

simulated function ClientShowSelection(RPGArtifact A)
{
    if(Interaction != None)
        Interaction.ShowSelection(A);
}

simulated function ClientCloseSelection()
{
    if(Interaction != None)
        Interaction.CloseSelection();
}

function bool AddFavorite(class<Weapon> WeaponClass, class<RPGWeaponModifier> ModifierClass)
{
    local RPGCharSettings.FavoriteWeaponStruct FW;
    local int i;

    for(i = 0; i < FavoriteWeapons.Length; i++) {
        if(FavoriteWeapons[i].WeaponClass == WeaponClass && FavoriteWeapons[i].ModifierClass == ModifierClass) {
            return false;
        }
    }

    FW.WeaponClass = WeaponClass;
    FW.ModifierClass = ModifierClass;

    FavoriteWeapons[FavoriteWeapons.Length] = FW;
    Interaction.CharSettings.FavoriteWeaponsConfig[Interaction.CharSettings.FavoriteWeaponsConfig.Length] = FW;

    return true;
}

function bool RemoveFavorite(class<Weapon> WeaponClass, class<RPGWeaponModifier> ModifierClass)
{
    local int i;

    for(i = 0; i < FavoriteWeapons.Length; i++) {
        if(FavoriteWeapons[i].WeaponClass == WeaponClass && FavoriteWeapons[i].ModifierClass == ModifierClass) {
            FavoriteWeapons.Remove(i, 1);
            Interaction.CharSettings.FavoriteWeaponsConfig.Remove(i, 1);
            return true;
        }
    }

    return false;
}

//grant queued weapons
function GrantQueuedWeapon(GrantWeapon GW) {
    local RPGWeaponModifier WM;
    local Weapon W;
    local int i;

    W = Controller.Pawn.Spawn(GW.WeaponClass);
    if(W != None) {
        if(GW.ModifierClass == None && !GW.bForce) {
            GW.ModifierClass = RPGMut.GetRandomWeaponModifier(
                GW.WeaponClass, Controller.Pawn);

            GW.Modifier = -100;
        }

        if(GW.ModifierClass != None) {
            WM = GW.ModifierClass.static.Modify(W, GW.Modifier, GW.bForce || RPGMut.GameSettings.bNoUnidentified);
        }

        //W.GiveTo(Controller.Pawn);
        class'Util'.static.ForceGiveTo(Controller.Pawn, W);
        W.FillToInitialAmmo();

        if(GW.Ammo[0] > 0) {
            class'Util'.static.SetWeaponAmmo(W, 0, GW.Ammo[0]);
        }

        if(GW.Ammo[1] > 0 && W.GetAmmoClass(1) != W.GetAmmoClass(0)) {
            class'Util'.static.SetWeaponAmmo(W, 1, GW.Ammo[1]);
        }

        for(i = 0; i < Abilities.Length; i++)
            if(Abilities[i].bAllowed)
                Abilities[i].ModifyGrantedWeapon(W, WM);
    }
}

function ProcessGrantQueue()
{
    local int i;

    if(Controller.Pawn == None)
        return;

    if(GrantFavQueue.Length == 0 && GrantQueue.Length == 0)
        return;

    //grant favorite weapons first
    for(i = 0; i < GrantFavQueue.Length; i++)
        GrantQueuedWeapon(GrantFavQueue[i]);

    GrantFavQueue.Length = 0;

    //now try the others
    for(i = 0; i < GrantQueue.Length; i++) {
        GrantQueuedWeapon(GrantQueue[i]);
    }

    GrantQueue.Length = 0;
}

//Add to weapon grant queue
function QueueWeapon(class<Weapon> WeaponClass, class<RPGWeaponModifier> ModifierClass, int Modifier, optional int Ammo1, optional int Ammo2, optional bool bForce)
{
    local int i;
    local GrantWeapon GW;

    WeaponClass = class<Weapon>(DynamicLoadObject(
        RPGMut.GetInventoryClassOverride(string(WeaponClass)), class'Class'));

    for(i = 0; i < Abilities.Length; i++) {
        if(Abilities[i].bAllowed) {
            if(!bForce) {
                if(!Abilities[i].OverrideGrantedWeapon(WeaponClass, ModifierClass, Modifier)) {
                    return; //not granted
                }
            }

            Abilities[i].OverrideGrantedWeaponAmmo(WeaponClass, Ammo1, Ammo2);
        }
    }

    GW.WeaponClass = WeaponClass;
    GW.ModifierClass = ModifierClass;
    GW.Modifier = Modifier;
    GW.Ammo[0] = Ammo1;
    GW.Ammo[1] = Ammo2;
    GW.bForce = bForce;

    if(IsFavorite(WeaponClass, ModifierClass)) {
        if(!bForce) {
            for(i = 0; i < GrantFavQueue.Length; i++) {
                if(
                    GrantFavQueue[i].WeaponClass == GW.WeaponClass &&
                    GrantFavQueue[i].ModifierClass == GW.ModifierClass
                ) {
                    //override in queue weapon if this modifier is higher, otherwise discard
                    if(GW.Modifier > GrantFavQueue[i].Modifier) {
                        GrantFavQueue[i].Modifier = GW.Modifier;
                    }

                    if(GW.Ammo[0] == -1 || GW.Ammo[0] > GrantFavQueue[i].Ammo[0]) {
                        GrantFavQueue[i].Ammo[0] = GW.Ammo[0];
                    }

                    if(GW.Ammo[1] == -1 || GW.Ammo[1] > GrantFavQueue[i].Ammo[1]) {
                        GrantFavQueue[i].Ammo[1] = GW.Ammo[1];
                    }

                    return;
                }
            }
        }

        GrantFavQueue[GrantFavQueue.Length] = GW;
    } else {
        if(!bForce) {
            for(i = 0; i < GrantQueue.Length; i++) {
                if(
                    GrantQueue[i].WeaponClass == GW.WeaponClass &&
                    GrantQueue[i].ModifierClass == GW.ModifierClass
                ) {
                    //override in queue weapon if this modifier is higher, otherwise discard
                    if(GW.Modifier > GrantQueue[i].Modifier) {
                        GrantQueue[i].Modifier = GW.Modifier;
                    }

                    if(GW.Ammo[0] == -1 || GW.Ammo[0] > GrantQueue[i].Ammo[0]) {
                        GrantQueue[i].Ammo[0] = GW.Ammo[0];
                    }

                    if(GW.Ammo[1] == -1 || GW.Ammo[1] > GrantQueue[i].Ammo[1]) {
                        GrantQueue[i].Ammo[1] = GW.Ammo[1];
                    }

                    return;
                }
            }
        }

        GrantQueue[GrantQueue.Length] = GW;
    }
}

//Find out whether a Weapon/Modifier combination is a favorite
simulated function bool IsFavorite(class<Weapon> WeaponClass, class<RPGWeaponModifier> ModifierClass, optional bool bWeaponOnly)
{
    local int i;

    for(i = 0; i < FavoriteWeapons.Length; i++)
    {
        if(
            WeaponClass == FavoriteWeapons[i].WeaponClass &&
            (bWeaponOnly || ModifierClass == FavoriteWeapons[i].ModifierClass)
        )
        {
            return true;
        }
    }
    return false;
}

simulated function NotifyFavorite(RPGWeaponModifier WeaponModifier)
{
    PlayerController(Controller).ReceiveLocalizedMessage(class'LocalMessage_FavoriteWeapon',,,, WeaponModifier);
}

simulated function ProcessProjectileMods() {
    local Projectile Proj, Closest;
    local float Dist, ClosestDist, Multiplier;
    local ProjectileMod Mod;
    local int i;

    i = 0;
    while(i < ModifyProjectiles.Length) {
        Mod = ModifyProjectiles[i];

        foreach CollidingActors(class'Projectile', Proj, PROJ_SEARCH_RADIUS, Mod.Location) {
            if(Proj.Tag != Mod.Flag && Proj.class == Mod.Type && Proj.Instigator == Mod.Instigator) {
                Dist = VSize(Proj.Location - Mod.Location);
                if(Closest == None || Dist < ClosestDist) {
                    Closest = Proj;
                    ClosestDist = Dist;
                }
            }
        }

        if(Closest != None) {
            ModifyProjectiles.Remove(i, 1);

            Multiplier = Mod.Vel / VSize(Closest.Velocity);
            //Log("Match (" $ (Mod.NumTicks + 1) $ ", " $ ClosestDist $ "):" @ Closest @ "*" @ Multiplier);

            Closest.Tag = Mod.Flag;
            Closest.SetLocation(Mod.Location); //TODO: interpolate?
            class'Util'.static.ModifyProjectileSpeed(Closest, Multiplier, Mod.Flag, Mod.FXClass);
        } else if(Mod.NumTicks >= 3) {
            ModifyProjectiles.Remove(i, 1);
            //Log("No match for:" @ Mod.Location @ Mod.Type @ Mod.Instigator);
        } else {
            ModifyProjectiles[i].NumTicks++;
            i++;
        }
    }
}

simulated function ClientSyncProjectile(vector Location, class<Projectile> Type, Pawn Instigator, float Vel, name Flag, class<Emitter> FXClass) {
    local ProjectileMod Mod;

    //Log("ClientSyncProjectile" @ Location @ Type @ Instigator);

    if(Role < ROLE_Authority) {
        Mod.NumTicks = 0;
        Mod.Location = Location;
        Mod.Type = Type;
        Mod.Instigator = Instigator;

        Mod.Vel = Vel;
        Mod.Flag = Flag;
        Mod.FXClass = FXClass;

        ModifyProjectiles[ModifyProjectiles.Length] = Mod;
    }
}

/*
centralized functions for adrenaline gain/drain, allowing modification of added or subtracted adrenaline
abilities and artifact should use these where possible
*/
final function AwardAdrenaline(float Amount, optional Object Source)
{
    local float OriginalAmount;
    local int i;
    local Inventory Inv;

    OriginalAmount = Amount;

    for(i = 0; i < Abilities.Length; i++)
        Abilities[i].ModifyAdrenalineGain(Amount, OriginalAmount, Source);
    if(Controller.Pawn != None)
    {
        for(Inv = Controller.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(RPGArtifact(Inv) != None && RPGArtifact(Inv).bActive)
                RPGArtifact(Inv).ModifyAdrenalineGain(Amount, OriginalAmount, Source);
            else if(RPGEffect(Inv) != None && RPGEffect(Inv).IsInState('Activated'))
                RPGEffect(Inv).ModifyAdrenalineGain(Amount, OriginalAmount, Source);
        }
    }

    Controller.AwardAdrenaline(Amount);
}

final function DrainAdrenaline(float Amount, optional Object Source)
{
    local float OriginalAmount;
    local int i;
    local Inventory Inv;

    OriginalAmount = Amount;

    for(i = 0; i < Abilities.Length; i++)
        Abilities[i].ModifyAdrenalineDrain(Amount, OriginalAmount, Source);
    if(Controller.Pawn != None)
    {
        for(Inv = Controller.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(RPGArtifact(Inv) != None && RPGArtifact(Inv).bActive)
                RPGArtifact(Inv).ModifyAdrenalineDrain(Amount, OriginalAmount, Source);
            else if(RPGEffect(Inv)!=None && RPGEffect(Inv).IsInState('Activated'))
                RPGEffect(Inv).ModifyAdrenalineDrain(Amount, OriginalAmount, Source);
        }
    }

    Controller.Adrenaline = FMax(Controller.Adrenaline - Amount, 0);
}

defaultproperties
{
    HealingExpMultiplier=0 //gotten from RPGRules

    LevelUpSound=Sound'TURRPG2.Effects.LevelUp'

    LockedVehicleOverlay=Shader'PulseRedShader'

    MaxMonsters=3
    MaxBuildings=15
    MaxSentinels=3
    MaxTurrets=3
    MaxVehicles=3
    MaxUtilities=3

    bMonstersDie=True
    bBuildingsDie=True
    bSentinelsDie=True
    bTurretsDie=True
    bVehiclesDie=True
    bUtilitiesDie=True

    bAlwaysRelevant=False
    bOnlyRelevantToOwner=True
    NetUpdateFrequency=4.000000
    RemoteRole=ROLE_SimulatedProxy
    GameRestartingText="Sorry, you cannot perform the desired action once the endgame voting has begun."
    ImposterText="Sorry, your name is already used on this server.|This is a roleplaying game server and every character has a unique name.||Please choose a different name and come back."
    LevelUpText="You have leveled up!|Head to the RPG menu (press L) to buy new abilities."
    IntroText="Press L to open the TURRPG menu."
}
