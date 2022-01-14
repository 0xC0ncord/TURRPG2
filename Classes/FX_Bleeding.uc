//=============================================================================
// FX_Bleeding.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Bleeding extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        UseRandomSubdivision=True
        Acceleration=(Z=-128.000000)
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=8
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=16.000000)
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Roll=16384)
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=12.000000,Max=16.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'XEffects.Skins.pcl_Blooda'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.600000)
    End Object
    Emitters(0)=SpriteEmitter'FX_Bleeding.SpriteEmitter0'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
