class Ability_ShieldBoosting extends RPGAbility;

var() float ShieldBoostingPercent;

//Client
var Interaction_EngineerAwareness Interaction;
var array<Pawn> Teammates;

replication {
    reliable if(Role == ROLE_Authority)
        ClientCreateInteraction;
}

simulated function ClientCreateInteraction()
{
    local PlayerController PC;
    local Ability_LoadedMedic MedicAbility;

    if(Level.NetMode != NM_DedicatedServer) {
        if(Interaction == None) {
            PC = Level.GetLocalPlayerController();
            if(PC == None) {
                return;
            }

            Interaction = Interaction_EngineerAwareness(
                PC.Player.InteractionMaster.AddInteraction("TURRPG2.Interaction_EngineerAwareness", PC.Player));

            Interaction.Ability = Self;

            // Tracked so that the shield bar doesn't overlay the health bar
            MedicAbility = Ability_LoadedMedic(RPRI.GetAbility(class'Ability_LoadedMedic'));
            Interaction.MedicAbility = MedicAbility;

            SetTimer(1.0, true);
        }
    }
}

simulated function Timer() {
    local PlayerController PC;
    local Pawn P;

    if(Interaction != None) {
        Teammates.Length = 0;

        PC = Level.GetLocalPlayerController();
        if(PC != None && PC.Pawn != None && PC.Pawn.Health > 0) {
            foreach DynamicActors(class'Pawn', P) {
                if(P == PC.Pawn) {
                    continue;
                }

                if(P.PlayerReplicationInfo == None || P.PlayerReplicationInfo.Team == None) {
                    continue;
                }

                if(P.GetTeamNum() == 255 || P.GetTeamNum() != PC.GetTeamNum()) {
                    continue;
                }

                if(Monster(P) != None || Vehicle(P) != None || P.DrivenVehicle != None) {
                    continue;
                }

                Teammates[Teammates.Length] = P;
            }
        }
    }
}

function ModifyPawn(Pawn Other) {
    Super.ModifyPawn(Other);

    if(Role == ROLE_Authority && Level.Game.bTeamGame)
        ClientCreateInteraction();
}

simulated event Destroyed() {
    if(Interaction != None) {
        Interaction.Master.RemoveInteraction(Interaction);
        Interaction = None;
    }

    Super.Destroyed();
}

defaultproperties
{
    GrantItem(0)=(Level=2,InventoryClass=Class'Artifact_ShieldBlast')
    ShieldBoostingPercent=3.000000
    AbilityName="Shield Boosting"
    Description="Allows the Engineer Link Gun to boost other teammates' shields."
    LevelDescription(0)="Level 1 enables the Engineer Link Gun's alt fire to boost shields."
    LevelDescription(1)="Level 2 doubles the experience for shield boosting."
    LevelDescription(2)="Level 3 tripes the experience."
    StartingCost=10
    CostAddPerLevel=5
    MaxLevel=3
    Category=class'AbilityCategory_Engineer'
}
