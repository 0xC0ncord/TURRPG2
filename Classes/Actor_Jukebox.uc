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
    /*
    RecordClasses(0)=class'Artifact_Record_AstrioCrystalWeed'
    RecordClasses(1)=class'Artifact_Record_BossfightCommandoSteve'
    RecordClasses(2)=class'Artifact_Record_C418Cat'
    RecordClasses(3)=class'Artifact_Record_C418Ward'
    RecordClasses(4)=class'Artifact_Record_ChipzelFocus'
    RecordClasses(5)=class'Artifact_Record_JakeChudnowGoingDown'
    RecordClasses(6)=class'Artifact_Record_LightningSpiritSoundsGymRemix'
    RecordClasses(7)=class'Artifact_Record_mindthingsSeaFrequency'
    RecordClasses(8)=class'Artifact_Record_MirroredTheoryGirlsInNeon'
    RecordClasses(9)=class'Artifact_Record_MirroredTheoryIDareYou'
    RecordClasses(10)=class'Artifact_Record_Mock2Crapca'
    RecordClasses(11)=class'Artifact_Record_MontyOnTheRunRemix'
    RecordClasses(12)=class'Artifact_Record_PortalStillAlive'
    RecordClasses(13)=class'Artifact_Record_RotMG'
    RecordClasses(14)=class'Artifact_Record_SpaceJam'
    RecordClasses(15)=class'Artifact_Record_SSBBCorneria'
    RecordClasses(16)=class'Artifact_Record_MarilynMansonPersonalJesus'
    RecordClasses(17)=class'Artifact_Record_CotNDAHotMess'
    RecordClasses(18)=class'Artifact_Record_CotNDDiscoDescent'
    RecordClasses(19)=class'Artifact_Record_CotNDKingConga'
    RecordClasses(20)=class'Artifact_Record_CotNDMausoleumMash'
    RecordClasses(21)=class'Artifact_Record_CotNDMetalmancy'
    RecordClasses(22)=class'Artifact_Record_CotNDTheWightToRemain'
    RecordClasses(23)=class'Artifact_Record_OriUpTheSpiritCavernsWalls'
    RecordClasses(24)=class'Artifact_Record_OriRidingTheWind'
    RecordClasses(25)=class'Artifact_Record_OriRestoringLightFacingDark'
    RecordClasses(26)=class'Artifact_Record_OriTheWatersCleansed'
    RecordClasses(27)=class'Artifact_Record_AceAttorney'
    RecordClasses(28)=class'Artifact_Record_BC'
    RecordClasses(29)=class'Artifact_Record_DSAshLake'
    RecordClasses(30)=class'Artifact_Record_DSGwyn'
    RecordClasses(31)=class'Artifact_Record_EDAndromeda'
    RecordClasses(32)=class'Artifact_Record_EDCanesVenatici'
    RecordClasses(33)=class'Artifact_Record_EDCombat'
    RecordClasses(34)=class'Artifact_Record_FTLCosmos'
    RecordClasses(35)=class'Artifact_Record_FTLLanius'
    RecordClasses(36)=class'Artifact_Record_FTLLastStand'
    RecordClasses(37)=class'Artifact_Record_FTLMilkyWay'
    RecordClasses(38)=class'Artifact_Record_ShiaLaBeouf'
    RecordClasses(39)=class'Artifact_Record_ADARefactor'
    RecordClasses(40)=class'Artifact_Record_UNDERTALEBonetrousle'
    RecordClasses(41)=class'Artifact_Record_UNDERTALEDeathByGlamour'
    RecordClasses(42)=class'Artifact_Record_UNDERTALEDummy'
    RecordClasses(43)=class'Artifact_Record_UNDERTALEHeartache'
    RecordClasses(44)=class'Artifact_Record_UNDERTALESpearOfJustice'
    RecordClasses(45)=class'Artifact_Record_UNDERTALESpiderDance'
    RecordClasses(46)=class'Artifact_Record_UNDERTALEMEGALOVANIA'
    RecordClasses(47)=class'Artifact_Record_TerrariaBossTwo'
    RecordClasses(48)=class'Artifact_Record_TerrariaBossFour'
    RecordClasses(49)=class'Artifact_Record_TerrariaPlantera'
    RecordClasses(50)=class'Artifact_Record_TerrariaSolarEclipse'
    RecordClasses(51)=class'Artifact_Record_HMCrystals'
    RecordClasses(52)=class'Artifact_Record_HMMiamiDisco'
    RecordClasses(53)=class'Artifact_Record_HMHotline'
    RecordClasses(54)=class'Artifact_Record_HMHydrogen'
    RecordClasses(55)=class'Artifact_Record_HMKnockKnock'
    RecordClasses(56)=class'Artifact_Record_HM2DecadeDance'
    RecordClasses(57)=class'Artifact_Record_HM2LePerv'
    RecordClasses(58)=class'Artifact_Record_HM2MsMinnie'
    RecordClasses(59)=class'Artifact_Record_HM2Quixotic'
    RecordClasses(60)=class'Artifact_Record_HM2RollerMobster'
    RecordClasses(61)=class'Artifact_Record_HM2Voyager'
    */
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
