//=============================================================================
// Ability_Awareness.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_Awareness extends RPGAbility;

//Client
var Interaction_Awareness Interaction;
var array<Pawn> Enemies;

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

            Interaction = Interaction_Awareness(
                PC.Player.InteractionMaster.AddInteraction("TURRPG2.Interaction_Awareness", PC.Player));

            Interaction.Ability = Self;

            SetTimer(1.0, true);
        }
    }
}

simulated function Timer() {
    local PlayerController PC;
    local Pawn P;

    if(Interaction != None) {
        Enemies.Length = 0;

        PC = Level.GetLocalPlayerController();
        if(PC != None && PC.Pawn != None && PC.Pawn.Health > 0) {
            foreach DynamicActors(class'Pawn', P) {
                if(P.GetTeamNum() != 255 && P.GetTeamNum() == PC.GetTeamNum()) {
                    continue;
                }

                if(P.DrivenVehicle != None) {
                    continue;
                }

                if(Vehicle(P) != None && ((!Vehicle(P).bDriving && !Vehicle(P).bAutoTurret) || Vehicle(P).GetVehicleBase() != None)) {
                    continue;
                }

                if(Interaction.GlobalInteraction != None && Interaction.GlobalInteraction.IsFriendlyPawn(P)) {
                    continue;
                }

                Enemies[Enemies.Length] = P;
            }
        }
    }
}

function ModifyPawn(Pawn Other) {
    Super.ModifyPawn(Other);

    if(Role == ROLE_Authority)
        ClientCreateInteraction();
}

simulated event Destroyed() {
    if(Interaction != None) {
        Interaction.Master.RemoveInteraction(Interaction);
        Interaction = None;
    }

    Super.Destroyed();
}

defaultproperties {
    AbilityName="Awareness"
    Description="Informs you of your enemies' health and shield."
    LevelDescription(0)="At level 1, a health bar will be displayed above the heads of enemies."
    LevelDescription(1)="At level 2, an additional shield bar will be displayed above the heads of enemies."
    StartingCost=20
    CostAddPerLevel=5
    MaxLevel=2
    Category=class'AbilityCategory_Misc'
}
