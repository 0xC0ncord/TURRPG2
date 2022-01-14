//=============================================================================
// FX_AbilityIconGlowUltra.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AbilityIconGlowUltra extends FX_AbilityIconEffect;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.900000),Z=(Min=0.500000,Max=0.600000))
        Opacity=0.500000
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
    Emitters(0)=SpriteEmitter'FX_AbilityIconGlowUltra.SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter7
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Opacity=0.500000
        FadeOutStartTime=0.350000
        FadeInEndTime=0.350000
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
        SpinsPerSecondRange=(X=(Min=-0.010000,Max=0.010000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.350000,RelativeSize=2.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Min=12.000000,Max=16.000000))
        Texture=Texture'VMParticleTextures.LeviathanParticleEffects.rainbowSpikes'
        LifetimeRange=(Min=1.000000,Max=1.200000)
    End Object
    Emitters(1)=SpriteEmitter'FX_AbilityIconGlowUltra.SpriteEmitter7'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Opacity=0.350000
        FadeOutStartTime=0.600000
        FadeInEndTime=0.200000
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
        SpinsPerSecondRange=(X=(Min=-0.020000,Max=0.020000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.250000)
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=1.000000,Max=1.100000)
    End Object
    Emitters(2)=SpriteEmitter'FX_AbilityIconGlowUltra.SpriteEmitter8'
}
