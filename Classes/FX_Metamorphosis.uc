//=============================================================================
// FX_Metamorphosis.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Metamorphosis extends RPGEmitter;

var float FXSizeMultiplier;

replication
{
    reliable if(Role == Role_Authority && bNetInitial)
        FXSizeMultiplier;
}

simulated function PostNetBeginPlay()
{
    if(Level.NetMode == NM_DedicatedServer)
        return;

    PlaySound(sound'SpawnConstruction', SLOT_Misc, 255,, 256);

    Emitters[0].StartSizeRange.X.Min *= FXSizeMultiplier;
    Emitters[0].StartSizeRange.X.Max *= FXSizeMultiplier;
    Emitters[1].StartSizeRange.X.Min *= FXSizeMultiplier;
    Emitters[1].StartSizeRange.X.Max *= FXSizeMultiplier;
    Emitters[2].StartSizeRange.X.Min *= FXSizeMultiplier;
    Emitters[2].StartSizeRange.X.Max *= FXSizeMultiplier;
    Emitters[3].StartLocationPolarRange.Z.Min *= FXSizeMultiplier;
    Emitters[3].StartLocationPolarRange.Z.Max *= FXSizeMultiplier;
    Emitters[4].SphereRadiusRange.Min *= FXSizeMultiplier;
    Emitters[4].SphereRadiusRange.Max *= FXSizeMultiplier;
    Emitters[5].StartSizeRange.X.Min *= FXSizeMultiplier;
    Emitters[5].StartSizeRange.X.Max *= FXSizeMultiplier;

    Emitters[0].Disabled = false;
    Emitters[1].Disabled = false;
    Emitters[2].Disabled = false;
    Emitters[3].Disabled = false;
    Emitters[4].Disabled = false;
    Emitters[5].Disabled = false;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        Disabled=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=1.000000
        FadeInEndTime=0.100000
        MaxParticles=2
        SpinsPerSecondRange=(X=(Min=-0.010000,Max=0.010000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=128.000000,Max=192.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Energy.BurnFlare'
        LifetimeRange=(Min=2.000000,Max=3.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        Disabled=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=4
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=128.000000,Max=128.000000))
        InitialParticlesPerSecond=25.000000
        Texture=Texture'AW-2004Particles.Fire.BlastMark'
        LifetimeRange=(Min=0.250000,Max=0.250000)
    End Object
    Emitters(1)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        Disabled=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.250000
        FadeInEndTime=0.250000
        MaxParticles=2
        SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=128.000000,Max=128.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaMuzzleBlue'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(2)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        Disabled=True
        UseDirectionAs=PTDU_Up
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeYByVelocity=True
        FadeOutStartTime=0.750000
        FadeInEndTime=0.250000
        MaxParticles=16
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=48.000000,Max=64.000000))
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Roll=16384)
        StartSizeRange=(X=(Min=8.000000,Max=12.000000))
        ScaleSizeByVelocityMultiplier=(Y=0.050000)
        Texture=Texture'AW-2004Particles.Energy.SparkHead'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(Y=(Min=-256.000000,Max=-256.000000))
    End Object
    Emitters(3)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        Disabled=True
        UseDirectionAs=PTDU_Right
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        ScaleSizeYByVelocity=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=32
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=64.000000,Max=64.000000)
        StartSpinRange=(X=(Min=0.500000,Max=0.500000))
        ScaleSizeByVelocityMultiplier=(Y=0.050000)
        InitialParticlesPerSecond=64.000000
        Texture=Texture'AW-2004Particles.Energy.Circleband1'
        LifetimeRange=(Min=0.300000,Max=0.250000)
        StartVelocityRadialRange=(Min=-64.000000,Max=-64.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(4)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        Disabled=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.250000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.800000)
        SizeScale(1)=(RelativeTime=0.025000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=192.000000,Max=192.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        LifetimeRange=(Min=3.500000)
    End Object
    Emitters(5)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter5'

    SoundVolume=255
    LifeSpan=4.000000
}
