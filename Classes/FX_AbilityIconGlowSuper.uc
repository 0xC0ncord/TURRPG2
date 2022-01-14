//=============================================================================
// FX_AbilityIconGlowSuper.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AbilityIconGlowSuper extends FX_AbilityIconEffect;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        FadeOut=True
        FadeIn=True
        UseRevolution=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.900000))
        FadeOutStartTime=0.600000
        FadeInEndTime=0.200000
        CoordinateSystem=PTCS_Relative
        MaxParticles=32
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=2.000000,Max=2.000000))
        RevolutionsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Yaw=16384)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.750000,RelativeSize=1.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=2.000000,Max=3.000000))
        Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
        LifetimeRange=(Min=0.900000,Max=1.100000)
        StartVelocityRadialRange=(Min=-36.000000,Max=-36.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_AbilityIconGlowSuper.SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.900000))
        Opacity=0.756000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.250000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(1)=SpriteEmitter'FX_AbilityIconGlowSuper.SpriteEmitter5'

}
