//=============================================================================
// FX_ComboReflectHit.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboReflectHit extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter15
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=0.250000,Max=0.300000)
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboReflectHit.SpriteEmitter15'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter16
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseRevolution=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        MaxParticles=6
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=1.000000,Max=1.000000)
        RevolutionsPerSecondRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=3.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.600000,Max=0.700000)
        StartVelocityRadialRange=(Min=-192.000000,Max=-256.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboReflectHit.SpriteEmitter16'

    AutoDestroy=True
    bNoDelete=False
    bNotOnDedServer=False
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=True
    bSkipActorPropertyReplication=True
}
