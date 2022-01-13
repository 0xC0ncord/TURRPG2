//=============================================================================
// FX_SummonersLinkBolt.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_SummonersLinkBolt extends RPGEmitter;

var Pawn Target;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Target;
}

simulated function PostNetBeginPlay()
{
    if(Role == ROLE_Authority)
        return;

    DoEffects();
}

simulated function DoEffects()
{
    local PlayerController PC;

    PC = Level.GetLocalPlayerController();

    if(PC==None || PC.ViewTarget == None || VSize(PC.ViewTarget.Location - Location) > 4000)
        return;

    SetRotation(rotator(Target.Location - Location));
    BeamEmitter(Emitters[1]).BeamDistanceRange.Min = VSize(Target.Location - Location);
    BeamEmitter(Emitters[1]).BeamDistanceRange.Max = VSize(Target.Location - Location);
    Emitters[2].StartLocationOffset = Target.Location;
    PlayOwnedSound(sound'HealthPack', SLOT_Misc, 0.60,,, 0.90 + (FRand() * 0.20));
    if(Target == PC.Pawn)
        PC.ClientFlash(0.90, vect(600.0, 0.0, 300.0));
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UniformSize=True
        AutomaticInitialSpawning=False
        RespawnDeadParticles=False
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.050000
        MaxParticles=1
        StartSizeRange=(X=(Min=16.000000,Max=24.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(0)=SpriteEmitter'FX_SummonersLinkBolt.SpriteEmitter0'

    Begin Object Class=BeamEmitter Name=BeamEmitter0
        BeamDistanceRange=(Min=512.000000,Max=512.000000)
        DetermineEndPointBy=PTEP_Distance
        HighFrequencyNoiseRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        AutomaticInitialSpawning=False
        RespawnDeadParticles=False
        UseRotationFrom=PTRS_Actor
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.050000
        MaxParticles=1
        StartSizeRange=(X=(Min=16.000000,Max=16.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Beams.HotBeam02aw'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(1)=BeamEmitter'FX_SummonersLinkBolt.BeamEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UniformSize=True
        AutomaticInitialSpawning=False
        RespawnDeadParticles=False
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.050000
        CoordinateSystem=PTCS_Absolute
        MaxParticles=1
        StartLocationOffset=(X=512.000000)
        StartSizeRange=(X=(Min=16.000000,Max=24.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=SpriteEmitter'FX_SummonersLinkBolt.SpriteEmitter2'

    bNetTemporary=True
}
