//=============================================================================
// FX_MedicSeeker.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_MedicSeeker extends Emitter;

defaultproperties
{
    Begin Object Class=TrailEmitter Name=TrailEmitter1
        TrailShadeType=PTTST_Linear
        TrailLocation=PTTL_FollowEmitter
        DistanceThreshold=32.000000
        PointLifeTime=0.250000
        FadeOut=True
        FadeIn=True
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=4
        StartSizeRange=(X=(Min=8.000000,Max=8.000000))
        Texture=Texture'AW-2004Particles.Weapons.TrailBlur'
        LifetimeRange=(Min=0.250000,Max=0.250000)
    End Object
    Emitters(0)=TrailEmitter'FX_MedicSeeker.TrailEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter24
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        UseRandomSubdivision=True
        FadeOutStartTime=0.100000
        FadeInEndTime=0.050000
        MaxParticles=6
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=8.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=4.000000,Max=8.000000))
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        LifetimeRange=(Min=0.250000,Max=0.250000)
    End Object
    Emitters(1)=SpriteEmitter'FX_MedicSeeker.SpriteEmitter24'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter25
        FadeOut=True
        FadeIn=True
        UniformSize=True
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=6
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=8.000000)
        StartSizeRange=(X=(Min=4.000000,Max=8.000000))
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=SpriteEmitter'FX_MedicSeeker.SpriteEmitter25'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter26
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=24.000000,Max=24.000000))
        Texture=Texture'AW-2004Particles.Fire.SmallBang'
        LifetimeRange=(Min=0.200000,Max=0.200000)
    End Object
    Emitters(3)=SpriteEmitter'FX_MedicSeeker.SpriteEmitter26'

    bNoDelete=False
    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
