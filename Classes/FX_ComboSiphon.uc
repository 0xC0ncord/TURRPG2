//=============================================================================
// FX_ComboSiphon.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboSiphon extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.900000),Z=(Min=0.700000))
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=8
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=32.000000,Max=48.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.300000)
        StartSizeRange=(X=(Min=4.000000,Max=6.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRadialRange=(Min=-48.000000,Max=-64.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboSiphon.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.900000),Z=(Min=0.700000))
        FadeOutStartTime=0.400000
        FadeInEndTime=0.200000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        SpinsPerSecondRange=(X=(Min=-0.015000,Max=0.015000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.700000)
        StartSizeRange=(X=(Min=72.000000,Max=96.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=0.600000,Max=0.700000)
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboSiphon.SpriteEmitter9'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter20
        FadeOut=True
        FadeIn=True
        UseRevolution=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        UseVelocityScale=True
        Opacity=0.300000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=12
        StartLocationRange=(Y=(Min=-32.000000,Max=32.000000))
        StartLocationShape=PTLS_All
        StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=16.000000,Max=16.000000))
        RevolutionsPerSecondRange=(Z=(Min=0.500000,Max=0.500000))
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Roll=16384)
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.800000,RelativeSize=3.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.200000)
        StartSizeRange=(X=(Min=32.000000,Max=48.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
        LifetimeRange=(Min=1.600000,Max=2.000000)
        StartVelocityRadialRange=(Min=64.000000,Max=96.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=0.750000,Y=0.750000,Z=0.200000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.050000))
    End Object
    Emitters(2)=SpriteEmitter'FX_ComboSiphon.SpriteEmitter20'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
