//=============================================================================
// FX_AbilityIconGlowBasic.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AbilityIconGlowBasic extends FX_AbilityIconEffect;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        FadeOutStartTime=0.600000
        FadeInEndTime=0.200000
        CoordinateSystem=PTCS_Relative
        MaxParticles=16
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=24.000000,Max=24.000000))
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Yaw=16384)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=3.000000))
        Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
        LifetimeRange=(Min=0.900000,Max=1.100000)
        StartVelocityRadialRange=(Min=-16.000000,Max=-16.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_AbilityIconGlowBasic.SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Opacity=0.500000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.250000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=24.000000,Max=28.000000))
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(1)=SpriteEmitter'FX_AbilityIconGlowBasic.SpriteEmitter3'
}
