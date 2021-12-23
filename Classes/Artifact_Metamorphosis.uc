//=============================================================================
// Artifact_Metamorphosis.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_Metamorphosis extends RPGArtifact
    dependson(Ability_Metamorphosis);

var Ability_Metamorphosis Ability;

var class<xPawn> PawnClass, DefaultPawnClass;
var bool bFlying;

var array<Ability_Metamorphosis.MonsterType> MonsterTypes;

var localized string SelectionTitle;
var localized string MsgFailed, MsgAlready, MsgNoSpace, MsgNoCrouch;

const MSG_Failed = 0x0001;
const MSG_Already = 0x0002;
const MSG_NoSpace = 0x0003;
const MSG_NoCrouch = 0x0004;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientReceiveMonsterType;
}

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_Failed:
            return default.MsgFailed;
        case MSG_Already:
            return default.MsgAlready;
        case MSG_NoSpace:
            return default.MsgNoSpace;
        case MSG_NoCrouch:
            return default.MsgNoCrouch;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

function SendMonsterTypes()
{
    local int i;
    local Ability_Metamorphosis.MonsterType M;

    for(i = 0; i < MonsterTypes.Length; i++)
    {
        M.DisplayName = MonsterTypes[i].DisplayName;
        M.Cost = MonsterTypes[i].Cost;
        ClientReceiveMonsterType(i, M);
    }
}

simulated function ClientReceiveMonsterType(int i, Ability_Metamorphosis.MonsterType M)
{
    local int x;

    if(Role < ROLE_Authority)
    {
        if(i == 0)
            MonsterTypes.Length = 0;

        x = MonsterTypes.Length;
        MonsterTypes.Length = x + 1;
        MonsterTypes[x] = M;
    }
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if(Role == ROLE_Authority)
    {
        DefaultPawnClass = class<xPawn>(DynamicLoadObject(Level.Game.DefaultPlayerClassName, class'Class'));
    }
}

function bool CanActivate()
{
    //hack for Venom munching
    if(Instigator.DrawType == DT_None)
        return false;

    //no cost until selection
    if(SelectedOption < 0)
        CostPerSec = 0;

    return Super.CanActivate();
}

function Activate()
{
    if(Instigator == None) //fixes an accessed none during transformation
        return;
    Super.Activate();
}

function OnSelection(int i)
{
    CostPerSec = MonsterTypes[i].Cost;
    Cooldown = MonsterTypes[i].Cooldown;
    PawnClass = MonsterTypes[i].MonsterClass;
    bFlying = MonsterTypes[i].bFlying;
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
    return MonsterTypes[i].DisplayName;
}

simulated function int GetOptionCost(int i)
{
    return MonsterTypes[i].Cost;
}

function int SelectBestOption()
{
    //too complicated for bots
    return -1;
}

function bool DoEffect()
{
    if(Instigator != None)
    {
        if(Instigator.Class == PawnClass)
        {
            Msg(MSG_Already);
            return false;
        }
        if(PawnClass == class'xPawn' && Instigator.Class == DefaultPawnClass)
        {
            Msg(MSG_Already);
            return false;
        }
        if(Instigator.bIsCrouched)
        {
            Msg(MSG_NoCrouch);
            return false;
        }
    }
    return Ability.Metamorphosize(Self, Instigator, PawnClass, bFlying, CostPerSec);
}

defaultproperties
{
    MsgFailed="Failed to transform into that monster."
    MsgAlready="You are already that form."
    MsgNoSpace="There is not enough room to transform into that monster."
    MsgNoCrouch="You cannot be crouched while using this artifact."
    SelectionTitle="Pick a monster to transform into:"
    CostPerSec=0
    HudColor=(B=255,G=64,R=64)
    ArtifactID="Metamorphosis"
    bSelection=True
    bCanBeTossed=False
    Description="Transforms you into a monster of your choice."
    IconMaterial=Texture'MetamorphosisIcon'
    ItemName="Metamorphic Charm"
}
