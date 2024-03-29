//=============================================================================
// RPGReplicationInfo.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGReplicationInfo extends ReplicationInfo;

const MAX_ARTIFACTS = 63;
const MAX_WEAPONMODIFIERS = 63;

var int NumAbilities;
var int NumWeaponModifiers;
var class<RPGArtifact> Artifacts[MAX_ARTIFACTS];
var class<RPGWeaponModifier> WeaponModifiers[MAX_WEAPONMODIFIERS];

//Client
var Interaction Interaction;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Artifacts, NumAbilities, WeaponModifiers;
}

static function RPGReplicationInfo Get(LevelInfo Level)
{
    local RPGReplicationInfo RRI;

    foreach Level.DynamicActors(class'RPGReplicationInfo', RRI)
        return RRI;

    return None;
}

simulated function ClientSetup(PlayerController PC)
{
    Interaction = PC.Player.InteractionMaster.AddInteraction(
        string(class'Interaction_Global'), PC.Player);
}

simulated event PostNetBeginPlay()
{
    local int i;

    Super.PostNetBeginPlay();

    if(Role < ROLE_Authority)
    {
        if(Interaction == None)
            ClientSetup(Level.GetLocalPlayerController());

        for(i = 0; i < MAX_WEAPONMODIFIERS; i++)
            if(WeaponModifiers[i] != None)
                NumWeaponModifiers++;
    }
}

simulated event Tick(float dt)
{
    local PlayerController PC;

    if(Level.NetMode == NM_Standalone)
    {
        PC = Level.GetLocalPlayerController();
        if(PC != None)
        {
            ClientSetup(PC);
            Disable('Tick');
        }
    }
    else
    {
        Disable('Tick');
    }
}

simulated event Destroyed()
{
    if(Interaction != None)
        Interaction.Master.RemoveInteraction(Interaction);

    Interaction = None;
    Super.Destroyed();
}

defaultproperties
{
     bReplicateMovement=False
}
