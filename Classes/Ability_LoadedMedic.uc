//=============================================================================
// Ability_LoadedMedic.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_LoadedMedic extends RPGAbility;

var array<int> LevelCap;

//Client
var Interaction_MedicAwareness Interaction;
var array<Pawn> Teammates;

replication {
    reliable if(Role == ROLE_Authority)
        ClientCreateInteraction;
}

simulated function ClientCreateInteraction()
{
    local PlayerController PC;

    if(Level.NetMode != NM_DedicatedServer) {
        if(Interaction == None) {
            PC = Level.GetLocalPlayerController();
            if(PC == None) {
                return;
            }

            Interaction = Interaction_MedicAwareness(
                PC.Player.InteractionMaster.AddInteraction("TURRPG2.Interaction_MedicAwareness", PC.Player));

            Interaction.Ability = Self;

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

function int GetHealMax()
{
    return LevelCap[AbilityLevel - 1];
}

simulated function string DescriptionText()
{
    local int i;
    local string Text;

    Text = Super.DescriptionText();

    for(i = 0; i < LevelCap.Length; i++)
        Text = repl(Text, "$" $ string(i + 1), string(LevelCap[i]));

    return Text;
}

defaultproperties
{
    AbilityName="Loaded Medic"
    Description="Gives you bonuses towards healing. Additionally, this ability informs you of your teammates' current health by displaying a team-colored health bar above their heads."
    LevelDescription(0)="Level 1 allows you to heal teammates +$1 beyond their maximum health."
    LevelDescription(1)="Level 2 allows you to heal teammates +$2 beyond their maximum health."
    LevelDescription(2)="Level 3 allows you to heal teammates +$3 beyond their maximum health."
    GrantItem(0)=(Level=1,InventoryClass=Class'Artifact_MakeMedicWeapon')
    GrantItem(1)=(Level=2,InventoryClass=Class'Artifact_SphereHealing')
    GrantItem(2)=(Level=3,InventoryClass=Class'Artifact_HealingBlast')
    StartingCost=10
    CostAddPerLevel=10
    MaxLevel=3
    LevelCap(0)=50
    LevelCap(1)=100
    LevelCap(2)=150
    Category=class'AbilityCategory_Medic'
}
