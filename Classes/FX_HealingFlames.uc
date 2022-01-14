//=============================================================================
// FX_HealingFlames.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_HealingFlames extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        UseRandomSubdivision=True
        Acceleration=(Z=128.000000)
        ColorScale(0)=(Color=(B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255))
        FadeOutStartTime=0.250000
        FadeInEndTime=0.250000
        MaxParticles=32
        InitialParticlesPerSecond=64.000000
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-16.000000,Max=16.000000),Y=(Min=-16.000000,Max=16.000000),Z=(Min=-32.000000,Max=32.000000))
        SpinsPerSecondRange=(X=(Min=-0.010000,Max=0.010000))
        StartSpinRange=(X=(Min=0.350000,Max=0.450000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=16.000000,Max=24.000000))
        Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=1.000000)
        StartVelocityRange=(Z=(Max=64.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_HealingFlames.SpriteEmitter0'

    Physics=PHYS_Trailer

    //so the effect dies off when it should... stupid but it works
    bAlwaysRelevant=True
}
