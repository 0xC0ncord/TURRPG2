//=============================================================================
// FX_AugmentExplosiveImpact.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AugmentExplosiveImpact extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter14
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=3
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=6.000000,Max=6.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=16.000000,Max=24.000000))
        InitialParticlesPerSecond=10.000000
        Texture=Texture'AW-2004Explosions.Fire.Part_explode2'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.400000,Max=0.600000)
    End Object
    Emitters(0)=SpriteEmitter'FX_AugmentExplosiveImpact.SpriteEmitter14'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter16
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.050000
        MaxParticles=1
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=2.000000,Max=2.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        InitialParticlesPerSecond=10.000000
        Texture=Texture'XEffects.Skins.Rexpt'
        LifetimeRange=(Min=0.300000,Max=0.300000)
    End Object
    Emitters(1)=SpriteEmitter'FX_AugmentExplosiveImpact.SpriteEmitter16'
}
