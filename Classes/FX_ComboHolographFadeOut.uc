//=============================================================================
// FX_ComboHolographFadeOut.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboHolographFadeOut extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        UseDirectionAs=PTDU_Up
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeXByVelocity=True
        ScaleSizeYByVelocity=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=900.000000)
        ColorScale(0)=(Color=(B=255,G=128,R=64))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=255))
        ColorMultiplierRange=(X=(Min=0.800000),Y=(Min=0.600000))
        FadeOutStartTime=0.450000
        FadeInEndTime=0.050000
        MaxParticles=16
        StartLocationRange=(Z=(Min=-32.000000,Max=32.000000))
        StartLocationShape=PTLS_All
        StartLocationPolarRange=(X=(Min=-32768.000000,Max=32768.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=16.000000,Max=12.000000))
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        ScaleSizeByVelocityMultiplier=(X=0.002000,Y=0.010000)
        InitialParticlesPerSecond=120.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.500000,Max=0.600000)
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboHolographFadeOut.SpriteEmitter8'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorMultiplierRange=(X=(Min=0.800000),Z=(Min=0.600000))
        FadeOutStartTime=0.400000
        FadeInEndTime=0.050000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboHolographFadeOut.SpriteEmitter9'

    AutoDestroy=True
    bNoDelete=False
}
