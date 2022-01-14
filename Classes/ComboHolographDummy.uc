//=============================================================================
// ComboHolographDummy.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboHolographDummy extends Actor;

var float AttractRadius;
var name HoloTauntAnims[10];
var name IdleAnim;
var Mesh HoloMesh[31];
var int TauntTime;

var ComboHolographDummyPawn Pawn;
var float CaramelldansenChance;
var bool bCaramelldansen;
var float NextLightChangeTime;
var byte CaramelldansenLightHues[8];

var PlayerController PC;

var FX_ComboHolographDummy FX;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        bCaramelldansen;
}

simulated function PostBeginPlay()
{
    if(Level.NetMode != NM_DedicatedServer)
    {
        FX = Spawn(class'FX_ComboHolographDummy', self,, Location);
        if(bCaramelldansen)
            DoCaramelldansen();
    }

    if(Role == ROLE_Authority)
    {
        Pawn = Spawn(class'ComboHolographDummyPawn', self,, self.Location + vect(0, 0, 150), self.Rotation);
        if(FRand() <= CaramelldansenChance)
        {
            bCaramelldansen = true;
            if(Level.NetMode != NM_DedicatedServer)
                DoCaramelldansen();
        }
        else
        {
            LinkMesh(HoloMesh[Rand(30)]);
            LoopAnim(IdleAnim);
        }
    }

    SetCollision(false, false, false);
    SetTimer(1.0, true);
}

simulated function DoCaramelldansen()
{
    PC = Level.GetLocalPlayerController();
    SetDrawType(DT_StaticMesh);
    SetDrawScale(0.35);
    PrePivot = vect(1, 0, -16);
    if(FRand() <= 0.5)
        Skins[0] = Texture'Mai00';
    else
        Skins[0] = Texture'Mii00';
    AmbientSound = Sound'Caramelldansen';
    LightType = LT_Steady;
    LightRadius = 12.0;
    LightHue = CaramelldansenLightHues[Rand(ArrayCount(CaramelldansenLightHues))];
    NextLightChangeTime = Level.TimeSeconds + 0.75;
}

simulated function Tick(float dt)
{
    local Actor A;
    local vector V;
    local rotator R;

    if(bCaramelldansen)
    {
        if(PC != None)
        {
            PC.PlayerCalcView(A, V, R);
            R = rotator(V - Location);
            R.Pitch = 0;
            R.Roll = 0;
            SetRotation(R);
        }

        if(Level.TimeSeconds > NextLightChangeTime)
            return;

        NextLightChangeTime = Level.TimeSeconds + 0.75;
        LightHue = CaramelldansenLightHues[Rand(ArrayCount(CaramelldansenLightHues))];
    }
    else
    {
        SetRotation(Rotation + rot(0, 2048, 0) * dt);
    }
}

simulated function Timer()
{
    local float decision;

    if(TauntTime >= 3 && Mesh != None)
    {
        decision = FRand();
        if(decision >= 0 && decision < 0.1)
        {
            PlayAnim(HoloTauntAnims[0],, 0.1);
        }
        else if(decision >= 0.1 && decision < 0.2)
        {
            PlayAnim(HoloTauntAnims[1],, 0.1);
        }
        else if(decision >= 0.2 && decision < 0.3)
        {
            PlayAnim(HoloTauntAnims[2],, 0.1);
        }
        else if(decision >= 0.3 && decision < 0.4)
        {
            PlayAnim(HoloTauntAnims[3],, 0.1);
        }
        else if(decision >= 0.4 && decision < 0.5)
        {
            PlayAnim(HoloTauntAnims[4],, 0.1);
        }
        else if(decision >= 0.5 && decision < 0.6)
        {
            PlayAnim(HoloTauntAnims[5],, 0.1);
        }
        else if(decision >= 0.6 && decision < 0.7)
        {
            PlayAnim(HoloTauntAnims[6],, 0.1);
        }
        else if(decision >= 0.7 && decision < 0.8)
        {
            PlayAnim(HoloTauntAnims[7],, 0.1);
        }
        else if(decision >= 0.8 && decision < 0.9)
        {
            PlayAnim(HoloTauntAnims[8],, 0.1);
        }
        else
        {
            PlayAnim(HoloTauntAnims[9],, 0.1);
        }
        TauntTime = 0;
    }
    TauntTime++;
}

simulated event AnimEnd(int Channel)
{
    LoopAnim(IdleAnim,, 0.25);
}

simulated function Destroyed()
{
    if(FX != None)
    {
        FX.Kill();
    }
    if(Pawn != None)
    {
        Pawn.Destroy();
    }

    if(Level.NetMode != NM_DedicatedServer)
        Spawn(class'FX_ComboHolographFadeOut', self,, Location);

    Super.Destroyed();
}

function Reset()
{
    Destroy();
}

defaultproperties
{
    AttractRadius=1500.000000
    CaramelldansenChance=0.010000
    CaramelldansenLightHues(0)=148
    CaramelldansenLightHues(1)=157
    CaramelldansenLightHues(2)=185
    CaramelldansenLightHues(3)=193
    CaramelldansenLightHues(4)=200
    CaramelldansenLightHues(5)=208
    CaramelldansenLightHues(6)=216
    CaramelldansenLightHues(7)=225
    HoloTauntAnims(0)="gesture_beckon"
    HoloTauntAnims(1)="gesture_cheer"
    HoloTauntAnims(2)="gesture_halt"
    HoloTauntAnims(3)="gesture_point"
    HoloTauntAnims(4)="Gesture_Taunt01"
    HoloTauntAnims(5)="AssSmack"
    HoloTauntAnims(6)="ThroatCut"
    HoloTauntAnims(7)="Specific_1"
    HoloTauntAnims(8)="PThrust"
    HoloTauntAnims(9)="Gesture_Taunt02"
    IdleAnim="Idle_Rest"
    HoloMesh(0)=SkeletalMesh'HumanFemaleA.MercFemaleB'
    HoloMesh(1)=SkeletalMesh'HumanFemaleA.NightFemaleB'
    HoloMesh(2)=SkeletalMesh'HumanFemaleA.NightFemaleA'
    HoloMesh(3)=SkeletalMesh'HumanFemaleA.EgyptFemaleA'
    HoloMesh(4)=SkeletalMesh'HumanFemaleA.EgyptFemaleB'
    HoloMesh(5)=SkeletalMesh'HumanFemaleA.MercFemaleA'
    HoloMesh(6)=SkeletalMesh'HumanFemaleA.MercFemaleC'
    HoloMesh(7)=SkeletalMesh'HumanMaleA.NightMaleA'
    HoloMesh(8)=SkeletalMesh'HumanMaleA.EgyptMaleA'
    HoloMesh(9)=SkeletalMesh'HumanMaleA.MercMaleA'
    HoloMesh(10)=SkeletalMesh'HumanMaleA.MercMaleB'
    HoloMesh(11)=SkeletalMesh'HumanMaleA.MercMaleC'
    HoloMesh(12)=SkeletalMesh'HumanMaleA.MercMaleD'
    HoloMesh(13)=SkeletalMesh'HumanMaleA.NightMaleA'
    HoloMesh(14)=SkeletalMesh'HumanMaleA.EgyptMaleB'
    HoloMesh(15)=SkeletalMesh'Aliens.AlienMaleA'
    HoloMesh(16)=SkeletalMesh'Aliens.AlienFemaleA'
    HoloMesh(17)=SkeletalMesh'Jugg.JuggFemaleA'
    HoloMesh(18)=SkeletalMesh'Jugg.JuggMaleA'
    HoloMesh(19)=SkeletalMesh'Bot.BotA'
    HoloMesh(20)=SkeletalMesh'Bot.BotB'
    HoloMesh(21)=SkeletalMesh'Bot.BotC'
    HoloMesh(22)=SkeletalMesh'Bot.BotD'
    HoloMesh(23)=SkeletalMesh'Hellions.Hellion__Female_Rae'
    HoloMesh(24)=SkeletalMesh'Hellions.Hellion_Garrett'
    HoloMesh(25)=SkeletalMesh'Hellions.Hellion_Kane'
    HoloMesh(26)=SkeletalMesh'Hellions.Hellion_Gitty'
    HoloMesh(27)=SkeletalMesh'XanRobots.XanM02'
    HoloMesh(28)=SkeletalMesh'XanRobots.EnigmaM'
    HoloMesh(29)=SkeletalMesh'XanRobots.XanF02'
    HoloMesh(30)=SkeletalMesh'XanRobots.XanM03'
    NetPriority=2.500000
    NetUpdateFrequency=8.000000
    DrawType=DT_Mesh
    StaticMesh=StaticMesh'SpriteSheet'
    Skins(0)=FinalBlend'HolographFB'
    Skins(1)=FinalBlend'HolographFB'
    bUnlit=True
    bDynamicLight=True
    bGameRelevant=True
    bAcceptsProjectors=False
    bCanBeDamaged=False
    bHardAttach=True
    CollisionRadius=25.000000
    CollisionHeight=44.000000
    bCollideActors=False
    bUseCylinderCollision=True
    bProjTarget=True
    bBlockZeroExtentTraces=False
    bBlockNonZeroExtentTraces=False
    RemoteRole=ROLE_SimulatedProxy
    SoundVolume=255
    SoundRadius=128.000000
    LightBrightness=192.000000
    LightSaturation=36
}
