//=============================================================================
// Actor_Jukebox.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Actor_Jukebox extends Actor;

var class<ArtifactBase_Record> CurrentRecordClass;
var string CurrentSong;

var int Health;
var bool bDestructible, bStopMusicWhenDestroyed;

var float RecordSpawnTime;

var array<PathNode> PathNodes;
var array<class<ArtifactBase_Record> > RecordClasses;

function PostBeginPlay()
{
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;

    PlaySound(Sound'JukeboxPlace', SLOT_Interact, 1.0, true, 768);

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(PlayerController(C) != None)
        {
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
            if(RPRI != None)
                RPRI.ClientCreateJukeboxInteraction();
        }
    }
}

function InitializeRecordSpawning()
{
    local NavigationPoint N;

    for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
        if(PathNode(N) != None && FlyingPathNode(N) == None)
            PathNodes[PathNodes.Length] = PathNode(N);

    if(Invasion(Level.Game) != None)
        SetTimer(RecordSpawnTime, true);
}

simulated function Destroyed()
{
    Spawn(class'FX_JukeboxBreak', self,, Location);
}

function PlaySong(ArtifactBase_Record Record, string SongArtist, string SongTitle, string SongAlbum, Material AlbumArt)
{
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;

    if(Record == None)
        return;

    EjectDisc();

    CurrentRecordClass = Record.Class;
    CurrentSong = Record.SongName;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(PlayerController(C) != None)
        {
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
            if(RPRI != None)
                RPRI.ClientJukeboxNowPlaying(CurrentSong, SongArtist, SongTitle, SongAlbum, AlbumArt, class'Artifact_Jukebox'.default.bForceMusic);
        }
    }
}

function EjectDisc()
{
    local ArtifactPickup_Record P;
    local vector V;

    if(CurrentRecordClass == None)
        return;

    P = Spawn(class<ArtifactPickup_Record>(CurrentRecordClass.default.PickupClass),,, Location + vect(0, 0, 72));
    if(P == None)
        return;
    P.InitDroppedPickupFor(None); //using None will force the pickup to spawn a new inventory item to give anyway
    V = 256 * VRand();
    V.Z = Abs(V.Z) * 2;
    P.Velocity = V;
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    local ArtifactPickup_Record P;
    local ArtifactPickup_Jukebox J;
    local vector V;
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;

    if(!bDestructible)
        return;

    Health -= Damage;

    if(Health <= 0)
    {
        if(CurrentRecordClass != None)
        {
            P = Spawn(class<ArtifactPickup_Record>(CurrentRecordClass.default.PickupClass),,, Location);
            if(P != None)
            {
                P.InitDroppedPickupFor(None);
                V = 64 * VRand();
                V.Z = Abs(V.Z);
                P.Velocity = V;
            }
        }
        J = Spawn(class'ArtifactPickup_Jukebox',,, Location);
        if(J != None)
        {
            J.InitDroppedPickupFor(None);
            V = 64 * VRand();
            V.Z = Abs(V.Z);
            J.Velocity = V;
        }

        if(bStopMusicWhenDestroyed)
        {
            for(C = Level.ControllerList; C != None; C = C.NextController)
            {
                if(PlayerController(C) != None)
                {
                    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
                    if(RPRI != None)
                        RPRI.ClientJukeboxDestroyed(CurrentSong != "");
                }
            }
        }
        Destroy();
    }
}

function Timer()
{
    local int Count, NumMonsters, CurrentMonster, PickedMonster;
    local PathNode PathNode;
    local class<ArtifactBase_Record> RecordClass;
    local RPGArtifact Inv;
    local Pickup APickup;
    local Controller C;

    RecordClass = RecordClasses[Rand(RecordClasses.Length)];

    if (Invasion(Level.Game) != None)
    {
        NumMonsters = int(Level.Game.GetPropertyText("NumMonsters"));
        if(NumMonsters > 0)
        {
            do
            {
                Count++;
                PickedMonster = Rand(NumMonsters);
                for (C = Level.ControllerList; C != None; C = C.NextController)
                {
                    if (Monster(C.Pawn) != None && FriendlyMonsterController(C) == None && PlayerController(C) == None)
                    {
                        if (CurrentMonster >= PickedMonster)
                        {
                            //Assumes monster doesn't get inventory from anywhere else!
                            if (RPGArtifact(C.Pawn.Inventory) == None)
                            {
                                Inv = Spawn(RecordClass);
                                if(Inv != None)
                                    Inv.GiveTo(C.Pawn);
                                break;
                            }
                        }
                        else
                            CurrentMonster++;
                    }
                }
            }
            until (Inv != None || Count > 1000)
        }
    }
    else
    {
        PathNode = FindSpawnLocation(RecordClass.default.PickupClass);
        if(PathNode != None)
        {
            APickup = Spawn(RecordClass.default.PickupClass,,, PathNode.Location);

            if (APickup == None)
                return;

            APickup.RespawnEffect();
            APickup.RespawnTime = 0.0;
            APickup.AddToNavigation();
            APickup.bDropped = true;
            APickup.Inventory = Spawn(RecordClass);
        }
    }
}

function PathNode FindSpawnLocation(class<Actor> ForWhat)
{
    local PathNode PathNode;
    local Pickup Pickup;
    local int i;
    local bool bAlreadyUsed;

    for(i = 0; i < 20; i++) //max 20 tries
    {
        PathNode = PathNodes[Rand(PathNodes.Length)];

        //check whether there's already a pickup here
        bAlreadyUsed = false;
        foreach PathNode.CollidingActors(class'Pickup', Pickup, ForWhat.default.CollisionRadius)
        {
            if(Pickup != None && FastTrace(PathNode.Location, Pickup.Location))
                bAlreadyUsed = true;
        }

        if(!bAlreadyUsed)
            return PathNode;
    }
    return None;
}

defaultproperties
{
    RecordClasses(0)=class'Artifact_Record_AceAttorney'
    RecordClasses(1)=class'Artifact_Record_100OJAlte'
    RecordClasses(2)=class'Artifact_Record_100OJHime'
    RecordClasses(3)=class'Artifact_Record_100OJKyoko'
    RecordClasses(4)=class'Artifact_Record_100OJMio'
    RecordClasses(5)=class'Artifact_Record_100OJQPDangerous'
    RecordClasses(6)=class'Artifact_Record_100OJSora'
    RecordClasses(7)=class'Artifact_Record_100OJSuguri'
    RecordClasses(8)=class'Artifact_Record_100OJSumika'
    RecordClasses(9)=class'Artifact_Record_100OJTsih'
    RecordClasses(10)=class'Artifact_Record_100OJ46BillionSuguri'
    Health=500
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'JukeboxMesh'
    bUseCollisionStaticMesh=True
    CollisionRadius=1.000000
    CollisionHeight=1.000000
    bCollideActors=True
    bBlockActors=True
    bBlockKarma=True
    bBlockNonZeroExtentTraces=True
    bBlockZeroExtentTraces=True
    bWorldGeometry=True
    bProjTarget=True
    RemoteRole=Role_DumbProxy
}
