//=============================================================================
// FX_AuraOrb_Heal.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AuraOrb_Heal extends FX_AuraOrb;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.300000,Max=0.400000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=12.000000,Max=16.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(0)=SpriteEmitter'FX_AuraOrb_Heal.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.300000,Max=0.400000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=16.000000,Max=16.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(1)=SpriteEmitter'FX_AuraOrb_Heal.SpriteEmitter2'

    Begin Object Class=TrailEmitter Name=TrailEmitter0
        TrailShadeType=PTTST_PointLife
        TrailLocation=PTTL_FollowEmitter
        MaxPointsPerTrail=150
        DistanceThreshold=32.000000
        UseCrossedSheets=True
        PointLifeTime=0.400000
        FadeOut=True
        FadeIn=True
        ResetAfterChange=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.400000,Max=0.400000))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=2
        StartSizeRange=(X=(Min=3.000000,Max=3.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.TrailBlur'
        LifetimeRange=(Min=1000.000000,Max=1000.000000)
    End Object
    Emitters(2)=TrailEmitter'FX_AuraOrb_Heal.TrailEmitter0'
}
