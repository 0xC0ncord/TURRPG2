//=============================================================================
// FX_ComboIronSpirit.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboIronSpirit extends RPGEmitter;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
        UseParticleColor=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.750000,Max=0.750000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(0)=MeshEmitter'FX_ComboIronSpirit.MeshEmitter2'

    Begin Object Class=TrailEmitter Name=TrailEmitter1
        TrailShadeType=PTTST_Linear
        UseCrossedSheets=True
        FadeOut=True
        FadeIn=True
        UseRevolution=True
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.900000))
        FadeOutStartTime=0.800000
        FadeInEndTime=0.200000
        MaxParticles=8
        StartLocationOffset=(Z=-44.000000)
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(X=(Min=-32768.000000,Max=32768.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=22.000000,Max=22.000000))
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=2.000000))
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(Z=(Min=88.000000,Max=88.000000))
    End Object
    Emitters(1)=TrailEmitter'FX_ComboIronSpirit.TrailEmitter1'

    Skins(0)=FinalBlend'PlasmaWhiteFinal'
    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
    bOwnerNoSee=True
}
