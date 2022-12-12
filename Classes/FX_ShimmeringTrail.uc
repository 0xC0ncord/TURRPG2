//=============================================================================
// FX_ShimmeringTrail.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ShimmeringTrail extends FX_MatrixTrail;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        UseRandomSubdivision=True
        UseVelocityScale=True
        ColorMultiplierRange=(X=(Min=0.800000,Max=1.200000),Y=(Min=0.800000,Max=1.200000))
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=6
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=1.000000,Max=1.000000)
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=4.000000,Max=6.000000))
        Texture=Texture'X_AW-Convert.Effects.StarPat2'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRadialRange=(Min=-48.000000,Max=-64.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_ShimmeringTrail.SpriteEmitter0'
}
