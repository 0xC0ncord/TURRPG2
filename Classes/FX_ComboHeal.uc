//=============================================================================
// FX_ComboHeal.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboHeal extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=27,G=27,R=27,A=255))
        ColorScale(1)=(RelativeTime=0.250000,Color=(B=71,G=228,R=122,A=255))
        ColorScale(2)=(RelativeTime=0.725000,Color=(B=60,G=196,R=141,A=255))
        ColorScale(3)=(RelativeTime=0.850000,Color=(B=192,G=192,R=192,A=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=53,G=49,R=232))
        Opacity=0.300000
        FadeOutStartTime=0.250000
        FadeInEndTime=0.004860
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
        StartLocationRange=(Z=(Min=-16.000000,Max=-16.000000))
        SpinsPerSecondRange=(X=(Min=7.000000,Max=7.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=8.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.620000)
        StartSizeRange=(X=(Min=6.600000,Max=32.800000),Y=(Min=6.612000,Max=32.800000),Z=(Min=6.612000,Max=32.800000))
        InitialParticlesPerSecond=48.000000
        Texture=Texture'TURRPG2.Effects.UC2_FX_Flares_05'
        LifetimeRange=(Min=0.460000,Max=0.460000)
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboHeal.SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-12.000000)
        ColorScale(0)=(Color=(B=27,G=27,R=27,A=255))
        ColorScale(1)=(RelativeTime=0.700000,Color=(B=95,G=205,R=122,A=255))
        ColorScale(2)=(RelativeTime=0.890000,Color=(B=38,G=194,R=217,A=255))
        ColorScale(3)=(RelativeTime=0.950000,Color=(B=192,G=192,R=192,A=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=53,G=49,R=232))
        Opacity=0.540000
        FadeOutStartTime=0.90000
        CoordinateSystem=PTCS_Relative
        MaxParticles=8
        StartLocationRange=(Z=(Min=-16.000000,Max=-16.000000))
        SpinsPerSecondRange=(X=(Min=7.000000,Max=7.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=10.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=6.600000,Max=14.330000),Y=(Min=6.600000,Max=14.330000),Z=(Min=6.600000,Max=14.330000))
        InitialParticlesPerSecond=48.000000
        Texture=Texture'TURRPG2.Effects.UC2_FX_Flares_05'
        LifetimeRange=(Min=0.900000,Max=1.000000)
        StartVelocityRange=(Z=(Min=-1.000000,Max=72.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboHeal.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        RespawnDeadParticles=False
        UseRevolution=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Opacity=0.500000
        FadeOutStartTime=0.150000
        CoordinateSystem=PTCS_Relative
        MaxParticles=80
        StartLocationOffset=(Z=-20.000000)
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=24.000000,Max=48.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.500000)
        SizeScale(1)=(RelativeTime=0.750000,RelativeSize=2.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=1.000000,Max=2.000000))
        InitialParticlesPerSecond=80.000000
        Texture=Texture'TURRPG2.Effects.UC2_FX_Flares_05'
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRange=(Z=(Min=96.000000,Max=160.000000))
        StartVelocityRadialRange=(Min=48.000000,Max=48.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(2)=SpriteEmitter'FX_ComboHeal.SpriteEmitter0'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
