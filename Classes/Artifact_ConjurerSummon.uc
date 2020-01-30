class Artifact_ConjurerSummon extends ArtifactBase_Summon
    config(TURRPG2);

struct MonsterTypeStruct
{
    var class<Monster> MonsterClass;
    var string FriendlyName;
    var int Cost;
    var int Points;
    var int Cooldown;
};
var config array<MonsterTypeStruct> MonsterTypes;

struct ReplicatedMonsterTypeStruct
{
    var string FriendlyName;
    var int Cost;
    var int Points;
};

var int PointsCost;

var array<int> PointsArray;

const MSG_MaxMonsters = 0x1000;
const MSG_NoPoints = 0x1100;

var localized string MsgMaxMonsters, SelectionTitle, MsgNoPoints;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientReceiveMonsterType;
}

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_MaxMonsters:
            return default.MsgMaxMonsters;
        case MSG_NoPoints:
            return default.MsgNoPoints;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

function SendMonsterTypes()
{
    local int i;
    local ReplicatedMonsterTypeStruct M;

    for(i = 0; i < MonsterTypes.Length; i++)
    {
        M.FriendlyName = MonsterTypes[i].FriendlyName;
        M.Cost = MonsterTypes[i].Cost;
        M.Points = MonsterTypes[i].Points;
        ClientReceiveMonsterType(i, M);
    }
}

simulated function ClientReceiveMonsterType(int i, ReplicatedMonsterTypeStruct M)
{
    local int x;

    if(Role < ROLE_Authority)
    {
        if(i == 0)
            MonsterTypes.Length = 0;

        x = MonsterTypes.Length;
        MonsterTypes.Length = x + 1;
        MonsterTypes[x].FriendlyName = M.FriendlyName;
        MonsterTypes[x].Cost = M.Cost;
        MonsterTypes[x].Points = M.Points;
    }
}

function bool CanActivate()
{
    if(SelectedOption < 0)
        CostPerSec = 0; //no cost until selection

    if(!Super.CanActivate())
        return false;

    if(InstigatorRPRI.Monsters.Length >= InstigatorRPRI.MaxMonsters || InstigatorRPRI.NumMonsters >= InstigatorRPRI.MaxMonsters)
    {
        Msg(MSG_MaxMonsters);
        return false;
    }

    if(InstigatorRPRI.MonsterPoints - PointsCost < 0)
    {
        PointsCost = 0;
        Msg(MSG_NoPoints);
        return false;
    }

    return true;
}

function Actor SpawnActor(class<Actor> SpawnClass, vector SpawnLoc, rotator SpawnRot)
{
    local FriendlyMonsterController C;
    local Monster M;

    M = Monster(Super.SpawnActor(SpawnClass, SpawnLoc, SpawnRot));
    if(M != None)
    {
        if(M.Controller != None)
            M.Controller.Destroy();

        C = Spawn(class'FriendlyMonsterController',,, SpawnLoc, Instigator.Rotation);
        C.Possess(M);
        C.SetMaster(Instigator.Controller);

        if(InstigatorRPRI != None)
            InstigatorRPRI.AddMonster(M, PointsCost);
        PointsArray.Remove(0, 1);

        ResetSelectionOptions();
    }
    return M;
}

function Failed()
{
    Super.Failed();
    InstigatorRPRI.NumMonsters--;
    InstigatorRPRI.MonsterPoints += PointsArray[0];
    PointsArray.Remove(0, 1);

    ResetSelectionOptions();
}

function RPGArtifactBeacon SpawnBeacon()
{
    local RPGArtifactBeacon Beacon;

    Beacon = Super.SpawnBeacon();
    if(Beacon_ConjurerSummon(Beacon) != None)
    {
        PointsArray[PointsArray.Length] = PointsCost;
        InstigatorRPRI.NumMonsters++;
        InstigatorRPRI.MonsterPoints -= PointsCost;
    }
    return Beacon;
}

function ResetSelectionOptions()
{
    CostPerSec = 0;
    Cooldown = 0;
    SpawnActorClass = None;
    PointsCost = 0;
}

function OnSelection(int i)
{
    CostPerSec = MonsterTypes[i].Cost;
    Cooldown = MonsterTypes[i].Cooldown;
    SpawnActorClass = MonsterTypes[i].MonsterClass;
    PointsCost = MonsterTypes[i].Points;
}

simulated function string GetSelectionTitle()
{
    return SelectionTitle;
}

simulated function int GetNumOptions()
{
    return MonsterTypes.Length;
}

simulated function string GetOption(int i)
{
    return MonsterTypes[i].FriendlyName;
}

simulated function int GetOptionCost(int i) {
    return MonsterTypes[i].Cost;
}

function int SelectBestOption() {
    local Controller C;
    local int i;

    C = Instigator.Controller;
    if(C != None) {
        //The AI assumes that the best options are listed last
        for(i = MonsterTypes.Length - 1; i >= 0; i--) {
            if(C.Adrenaline >= MonsterTypes[i].Cost && FRand() < 0.5) {
                return i;
            }
        }

        //None
        return -1;
    } else {
        return Super.SelectBestOption();
    }
}

exec function Summon(string Chosen)
{
    local int i;

    for(i = 0; i < MonsterTypes.Length; i++)
        if(MonsterTypes[i].FriendlyName ~= Repl(Chosen, "_", " "))
            break;

    SelectedOption = i;
    CostPerSec = MonsterTypes[i].Cost;
    Cooldown = MonsterTypes[i].Cooldown;
    SpawnActorClass = MonsterTypes[i].MonsterClass;
    PointsCost = MonsterTypes[i].Points;
    Activate();
}

defaultproperties
{
     MsgMaxMonsters="You cannot spawn any more monsters at this time."
     MsgNoPoints="Insufficient monster points available to summon this monster."
     SelectionTitle="Pick a monster to summon:"
     CostPerSec=0
     HudColor=(B=96,G=64,R=192)
     ArtifactID="MonsterSummon"
     bSelection=True
     bCanBeTossed=False
     Description="Summons a friendly monster of your choice."
     IconMaterial=Texture'TURRPG2.ArtifactIcons.MonsterSummon'
     ItemName="Summoning Charm"
     BeaconClass=Class'TURRPG2.Beacon_ConjurerSummon'
}
