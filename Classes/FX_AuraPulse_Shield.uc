//=============================================================================
// FX_AuraPulse_Shield.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AuraPulse_Shield extends FX_AuraPulse;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'ParticleMeshes.Complex.IonSphere'
        UseParticleColor=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Z=(Min=0.000000,Max=0.200000))
        Opacity=0.500000
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(Z=(Min=0.500000,Max=0.500000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.700000,Max=0.700000)
    End Object
    Emitters(0)=MeshEmitter'FX_AuraPulse_Shield.MeshEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Z=(Min=0.000000,Max=0.200000))
        Opacity=0.750000
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(1)=SpriteEmitter'FX_AuraPulse_Shield.SpriteEmitter0'
}
