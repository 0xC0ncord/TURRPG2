//=============================================================================
// Artifact_Jukebox.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_Jukebox extends RPGArtifact
    config(TURRPG2);

var array<class<Actor> > BlockingTypes;

var localized string MsgCantConstruct;
var localized array<string> BlockingTypeStrings;

const MSG_TooFar = 0x0001;
const MSG_NoRoom = 0x0002;
const MSG_Exists = 0x0003;
const MSG_Ground = 0x0004;
const MSG_CantConstruct = 0x005;
var localized string MSG_Text_TooFar,
                     MSG_Text_NoRoom,
                     MSG_Text_Exists,
                     MSG_Text_Ground;

var() config float ClearRadius;
var() config bool bForceMusic; //if true, players will be forced to listen to music
                             //even if they turned their music off
var() config bool bDestructible; //if true, the jukebox can take damage and be destroyed
var() config bool bStopMusicWhenDestroyed;
var() config float RecordSpawnTime;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    if((Msg & MSG_CantConstruct) == MSG_CantConstruct)
        return Repl(default.MsgCantConstruct, "$1", default.BlockingTypeStrings[Msg & 0xFF]);
    switch(Msg)
    {
        case MSG_TooFar:
            return default.MSG_Text_TooFar;
        case MSG_NoRoom:
            return default.MSG_Text_NoRoom;
        case MSG_Exists:
            return default.MSG_Text_Exists;
        case MSG_Ground:
            return default.MSG_Text_Ground;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

final function bool CheckSpace(vector SpawnLocation, int HorizontalSpaceReqd, int VerticalSpaceReqd)
{
    if (!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 0, 1) * VerticalSpaceReqd)))
        return false;

    if (!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 1, 0) * HorizontalSpaceReqd))
        && !FastTrace(SpawnLocation, SpawnLocation - (vect(0, 1, 0) * HorizontalSpaceReqd) ))
        return false;

    if (!FastTrace(SpawnLocation, SpawnLocation + (vect(1, 0, 0) * HorizontalSpaceReqd))
        && !FastTrace(SpawnLocation, SpawnLocation - (vect(1, 0, 0) * HorizontalSpaceReqd) ))
        return false;

    return true;
}

function bool DoEffect()
{
    local vector SpawnLoc;
    local vector HitNormal;
    local rotator R;
    local vector V;
    local Actor A;
    local int i, Blocker;
    local Actor_Jukebox Juke;

    if(Instigator == None || Instigator.Controller == None)
        return false;

    foreach DynamicActors(class'Actor_Jukebox', Juke)
        if(Juke != None)
            break;
    if(Juke != None)
    {
        Msg(MSG_Exists);
        return false;
    }

    if(PlayerController(Instigator.Controller).bBehindView)
        PlayerController(Instigator.Controller).PlayerCalcView(A, V, R);
    else
        R = Instigator.Controller.GetViewRotation();

    Trace(SpawnLoc, HitNormal, Instigator.Location + Instigator.EyePosition() + (vector(R) * 256), Instigator.Location + Instigator.EyePosition());
    if(SpawnLoc == vect(0, 0, 0))
    {
        Msg(MSG_TooFar);
        return false;
    }

    if(FastTrace(SpawnLoc, SpawnLoc - (vect(0, 0, 1) * 32)))
    {
        Msg(MSG_Ground);
        return false;
    }

    SpawnLoc += vect(0, 0, 32);

    if(!CheckSpace(SpawnLoc, 48, 90))
    {
        Msg(MSG_NoRoom);
        return false;
    }

    Blocker = -1;
    foreach RadiusActors(class'Actor', A, ClearRadius, SpawnLoc)
    {
        for(i = 0; i < BlockingTypes.Length; i++)
        {
            if(ClassIsChildOf(A.Class, BlockingTypes[i]))
            {
                Blocker = i;
                break;
            }
        }
    }

    if(Blocker >= 0)
    {
        Msg(MSG_CantConstruct | Blocker);
        return false;
    }

    R = rot(0, 0, 0);
    R.Yaw = Rand(16384);
    Juke = Spawn(class'Actor_Jukebox',,, SpawnLoc, R);
    if(Juke == None)
        return false;
    Juke.bDestructible = bDestructible;
    Juke.bStopMusicWhenDestroyed = bStopMusicWhenDestroyed;
    Juke.RecordSpawnTime = RecordSpawnTime;
    Juke.InitializeRecordSpawning();
    RemoveOne();
    return true;
}

defaultproperties
{
    MSG_Text_TooFar="The spawn location is too far."
    MSG_Text_NoRoom="There is not enough room around the spawn location."
    MSG_Text_Exists="There is already another Jukebox in play."
    MSG_Text_Ground="The Jukebox must be placed on the ground!"
    RecordSpawnTime=30.000000
    bDestructible=True
    bStopMusicWhenDestroyed=True
    ClearRadius=48.000000
    BlockingTypes(0)=Class'UnrealGame.GameObjective'
    BlockingTypes(1)=Class'Engine.PlayerStart'
    BlockingTypes(2)=Class'Engine.SVehicleFactory'
    BlockingTypes(3)=Class'Engine.Teleporter'
    BlockingTypes(4)=Class'Engine.LiftExit'
    BlockingTypes(5)=Class'Engine.LiftCenter'
    BlockingTypes(6)=Class'Engine.xPickUpBase'
    BlockingTypes(7)=Class'XWeapons.WeaponLocker'
    MsgCantConstruct="Cannot construct here because of a nearby $1."
    BlockingTypeStrings(0)="game objective"
    BlockingTypeStrings(1)="player start"
    BlockingTypeStrings(2)="vehicle spawn"
    BlockingTypeStrings(3)="teleporter"
    BlockingTypeStrings(4)="lift exit"
    BlockingTypeStrings(5)="lift"
    BlockingTypeStrings(6)="pickup base"
    BlockingTypeStrings(7)="weapon locker"
    MinActivationTime=0.000000
    PickupClass=Class'ArtifactPickup_Jukebox'
    IconMaterial=Texture'JukeboxIcon'
    ItemName="Jukebox"
    ArtifactID="Jukebox"
    Description="Plays records when placed."
    HudColor=(R=128,G=192,B=128)
}
