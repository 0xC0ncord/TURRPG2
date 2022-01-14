//=============================================================================
// FX_ComboSiphonOrb.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboSiphonOrb extends Emitter;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
        UseParticleColor=True
        UniformSize=True
        AutomaticInitialSpawning=False
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSizeRange=(X=(Min=0.100000,Max=0.100000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(0)=MeshEmitter'FX_ComboSiphonOrb.MeshEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter13
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(B=255,R=128))
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255))
        Opacity=0.500000
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.050000)
        StartSizeRange=(X=(Min=12.000000,Max=14.000000))
        Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
        LifetimeRange=(Min=0.500000,Max=0.600000)
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboSiphonOrb.SpriteEmitter13'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter14
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.200000
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
        SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.250000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'AW-2004Particles.Energy.AirBlast'
        LifetimeRange=(Min=0.700000,Max=0.700000)
    End Object
    Emitters(2)=SpriteEmitter'FX_ComboSiphonOrb.SpriteEmitter14'

    Skins(0)=Combiner'SiphonOrbComb'
    AutoDestroy=True
    bNoDelete=False
    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
