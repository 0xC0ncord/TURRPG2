//=============================================================================
// FX_BlastExplosion_MonsterUltima.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_BlastExplosion_MonsterUltima extends FX_BlastExplosion;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        RespawnDeadParticles=False
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=-200.000000,Max=200.000000)
        StartSpinRange=(X=(Min=1.055000,Max=2.355000))
        SizeScale(0)=(RelativeTime=3.000000,RelativeSize=5.000000)
        StartSizeRange=(X=(Min=150.000000,Max=150.000000))
        InitialParticlesPerSecond=1500.000000
        Texture=Texture'VMParticleTextures.VehicleExplosions.VMExp2_framesANIM'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(0)=SpriteEmitter'FX_BlastExplosion_MonsterUltima.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        FadeOut=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        RespawnDeadParticles=False
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        FadeOutStartTime=0.100000
        MaxParticles=1
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
        InitialParticlesPerSecond=20.000000
        Texture=Texture'ONSstructureTextures.CoreGroup.CoreBreachShockRINGorange'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(1)=SpriteEmitter'FX_BlastExplosion_MonsterUltima.SpriteEmitter1'

}
