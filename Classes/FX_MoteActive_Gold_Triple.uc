//=============================================================================
// FX_MoteActive_Gold_Triple.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_MoteActive_Gold_Triple extends FX_MoteActive_Triple;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter47
        UseRevolution=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=32.000000,Z=-8.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=None
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.250000)
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(Z=-1.000000))
        VelocityScale(3)=(RelativeTime=0.750000)
        VelocityScale(4)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter47'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter46
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        Acceleration=(Z=24.000000)
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.400000))
        Opacity=0.500000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=24
        AddLocationFromOtherEmitter=0
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=4.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=12.000000,Max=16.000000))
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=1.000000,Max=1.200000)
        StartVelocityRange=(Z=(Min=16.000000,Max=24.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter46'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter48
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.600000))
        Opacity=0.500000
        FadeOutStartTime=0.070000
        FadeInEndTime=0.020000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartLocationOffset=(Z=8.000000)
        AddLocationFromOtherEmitter=0
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=18.000000,Max=24.000000))
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(2)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter48'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter49
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        Acceleration=(Z=48.000000)
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.400000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        AddLocationFromOtherEmitter=0
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.200000)
        StartSizeRange=(X=(Min=3.000000,Max=4.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlickerFlare'
        LifetimeRange=(Min=0.700000,Max=0.800000)
        StartVelocityRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=12.000000,Max=24.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=1.000000))
    End Object
    Emitters(3)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter49'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter59
        UseRevolution=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=-16.000000,Y=-28.000000,Z=-8.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=None
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(Z=(Min=-64.000000,Max=-64.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.250000)
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(Z=-1.000000))
        VelocityScale(3)=(RelativeTime=0.750000)
        VelocityScale(4)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(4)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter59'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter60
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        Acceleration=(Z=24.000000)
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.400000))
        Opacity=0.500000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=24
        AddLocationFromOtherEmitter=4
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=4.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=12.000000,Max=16.000000))
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=1.000000,Max=1.200000)
        StartVelocityRange=(Z=(Min=16.000000,Max=24.000000))
    End Object
    Emitters(5)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter60'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter61
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.600000))
        Opacity=0.500000
        FadeOutStartTime=0.070000
        FadeInEndTime=0.020000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartLocationOffset=(Z=8.000000)
        AddLocationFromOtherEmitter=4
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=18.000000,Max=24.000000))
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(6)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter61'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter62
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        Acceleration=(Z=48.000000)
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.400000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        AddLocationFromOtherEmitter=4
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.200000)
        StartSizeRange=(X=(Min=3.000000,Max=4.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlickerFlare'
        LifetimeRange=(Min=0.700000,Max=0.800000)
        StartVelocityRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=12.000000,Max=24.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=1.000000))
    End Object
    Emitters(7)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter62'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter65
        UseRevolution=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=-16.000000,Y=28.000000,Z=-8.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=None
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.250000)
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(Z=-1.000000))
        VelocityScale(3)=(RelativeTime=0.750000)
        VelocityScale(4)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(8)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter65'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter66
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        Acceleration=(Z=24.000000)
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.400000))
        Opacity=0.500000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=24
        AddLocationFromOtherEmitter=8
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=4.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=12.000000,Max=16.000000))
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=1.000000,Max=1.200000)
        StartVelocityRange=(Z=(Min=16.000000,Max=24.000000))
    End Object
    Emitters(9)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter66'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter67
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.600000))
        Opacity=0.500000
        FadeOutStartTime=0.070000
        FadeInEndTime=0.020000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartLocationOffset=(Z=8.000000)
        AddLocationFromOtherEmitter=8
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=18.000000,Max=24.000000))
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(10)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter67'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter68
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        Acceleration=(Z=48.000000)
        ColorMultiplierRange=(Z=(Min=0.200000,Max=0.400000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        AddLocationFromOtherEmitter=8
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.200000)
        StartSizeRange=(X=(Min=3.000000,Max=4.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlickerFlare'
        LifetimeRange=(Min=0.700000,Max=0.800000)
        StartVelocityRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=12.000000,Max=24.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=1.000000))
    End Object
    Emitters(11)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter68'

}

