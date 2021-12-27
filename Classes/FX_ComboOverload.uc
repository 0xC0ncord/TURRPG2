//=============================================================================
// FX_ComboOverload.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboOverload extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseColorScale=True
        FadeOut=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Acceleration=(Z=8.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.600000,Color=(B=38,G=176,R=217,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=61,G=57,R=185,A=255))
        FadeOutStartTime=0.260610
        CoordinateSystem=PTCS_Relative
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.370000,RelativeSize=0.360000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=32.000000,Max=48.000000))
        InitialParticlesPerSecond=9.103000
        Texture=Texture'UC2_WavyA01'
        LifetimeRange=(Min=0.511000,Max=0.511000)
        InitialDelayRange=(Min=0.020000,Max=0.020000)
        StartVelocityRange=(X=(Min=-0.800000,Max=0.800000),Y=(Min=-0.800000,Max=0.800000),Z=(Min=128.000000,Max=128.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboOverload.SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        FadeOut=True
        FadeIn=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        BlendBetweenSubdivisions=True
        Acceleration=(Z=16.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=61,G=57,R=185,A=255))
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.433000,Max=0.433000))
        FadeOutStartTime=0.492020
        FadeInEndTime=0.350480
        CoordinateSystem=PTCS_Relative
        SizeScale(0)=(RelativeSize=0.660000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.328000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.150000)
        StartSizeRange=(X=(Min=32.000000,Max=48.000000))
        InitialParticlesPerSecond=9.103000
        Texture=Texture'UC2_Flamesq2'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.674000,Max=0.674000)
        InitialDelayRange=(Min=0.020000,Max=0.020000)
        StartVelocityRange=(X=(Min=-1.315000,Max=1.315000),Y=(Min=-1.315000,Max=1.315000),Z=(Min=96.000000,Max=96.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboOverload.SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter10
        UseDirectionAs=PTDU_Up
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UniformSize=True
        ScaleSizeYByVelocity=True
        Acceleration=(Z=-900.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.600000,Color=(G=179,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=14,G=82,R=241))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.050000
        MaxParticles=8
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=3.000000,Max=4.000000)
        StartSizeRange=(X=(Min=2.000000,Max=3.000000))
        ScaleSizeByVelocityMultiplier=(Y=0.020000)
        Texture=Texture'AW-2004Particles.Energy.SparkHead'
        LifetimeRange=(Min=0.250000,Max=0.300000)
        StartVelocityRange=(Z=(Min=128.000000,Max=256.000000))
        StartVelocityRadialRange=(Min=-256.000000,Max=-384.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(2)=SpriteEmitter'FX_ComboOverload.SpriteEmitter10'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
    bOwnerNoSee=True
}
