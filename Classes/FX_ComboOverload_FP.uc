//=============================================================================
// FX_ComboOverload_FP.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboOverload_FP extends RPGEmitter;

defaultproperties
{
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
    Emitters(0)=SpriteEmitter'FX_ComboOverload_FP.SpriteEmitter10'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
    bOnlyOwnerSee=True
    bOnlyRelevantToOwner=True
}
