//=============================================================================
// FX_VacuumingAbsorb.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_VacuumingAbsorb extends RPGEmitter;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'XEffects.EffectsSphere144'
        UseParticleColor=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        Opacity=0.350000
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.500000,Max=0.600000)
    End Object
    Emitters(0)=MeshEmitter'FX_VacuumingAbsorb.MeshEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter17
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Y=(Min=0.400000,Max=0.600000))
        Opacity=0.500000
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=3
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
        StartSizeRange=(X=(Min=72.000000,Max=72.000000))
        InitialParticlesPerSecond=10.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'X_AW-Convert.sky.AW-Nebula4'
        LifetimeRange=(Min=0.500000,Max=0.600000)
    End Object
    Emitters(1)=SpriteEmitter'FX_VacuumingAbsorb.SpriteEmitter17'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter18
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Y=(Min=0.400000,Max=0.600000))
        Opacity=0.250000
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
        StartSizeRange=(X=(Min=64.000000,Max=64.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'XEffectMat.Shock.Shock_ring_a'
        LifetimeRange=(Min=0.600000,Max=0.600000)
    End Object
    Emitters(2)=SpriteEmitter'FX_VacuumingAbsorb.SpriteEmitter18'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter19
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Y=(Min=0.300000,Max=0.400000))
        Opacity=0.250000
        FadeOutStartTime=0.400000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=72.000000,Max=72.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.700000,Max=0.800000)
    End Object
    Emitters(3)=SpriteEmitter'FX_VacuumingAbsorb.SpriteEmitter19'
}
