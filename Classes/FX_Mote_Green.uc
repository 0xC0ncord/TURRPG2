//=============================================================================
// FX_Mote_Green.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Mote_Green extends FX_Mote;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter50
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        Acceleration=(Z=24.000000)
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.150000),Z=(Min=0.000000,Max=0.200000))
        Opacity=0.500000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=12
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=8.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=18.000000,Max=24.000000))
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=1.000000,Max=1.200000)
        StartVelocityRange=(Z=(Min=24.000000,Max=32.000000))
        StartVelocityRadialRange=(Min=-6.000000,Max=-8.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_Mote_Green.SpriteEmitter50'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter51
        UseDirectionAs=PTDU_Up
        FadeOut=True
        FadeIn=True
        UniformSize=True
        UseRandomSubdivision=True
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.150000),Z=(Min=0.000000,Max=0.200000))
        Opacity=0.500000
        FadeOutStartTime=0.100000
        FadeInEndTime=0.020000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartLocationOffset=(Z=20.000000)
        StartSizeRange=(X=(Min=28.000000,Max=32.000000))
        Texture=Texture'ONSBPTextures.fX.Fire'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(Z=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_Mote_Green.SpriteEmitter51'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter52
        SpinParticles=True
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.150000),Z=(Max=0.200000))
        Opacity=0.700000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(Z=10.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(2)=SpriteEmitter'FX_Mote_Green.SpriteEmitter52'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter53
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        Acceleration=(Z=64.000000)
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.150000),Z=(Min=0.000000,Max=0.200000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.200000)
        StartSizeRange=(X=(Min=3.000000,Max=4.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlickerFlare'
        LifetimeRange=(Min=0.700000,Max=0.800000)
        StartVelocityRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=16.000000,Max=32.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=1.000000))
    End Object
    Emitters(3)=SpriteEmitter'FX_Mote_Green.SpriteEmitter53'

}
