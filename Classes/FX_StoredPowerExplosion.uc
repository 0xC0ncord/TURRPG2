//=============================================================================
// FX_StoredPowerExplosion.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_StoredPowerExplosion extends RPGEmitter;

replication
{
    reliable if(Role == ROLE_Authority)
        Init;
}

simulated function Init(float Multiplier)
{
    Emitters[3].StartVelocityRadialRange.Min *= Multiplier;
    Emitters[3].StartVelocityRadialRange.Max *= Multiplier;
    Emitters[3].StartSizeRange.X.Min *= Multiplier;
    Emitters[3].StartSizeRange.X.Max *= Multiplier;
    Emitters[4].StartSizeRange.X.Min *= Multiplier;
    Emitters[4].StartSizeRange.X.Max *= Multiplier;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Y=(Min=0.500000,Max=0.500000))
        Opacity=0.500000
        FadeOutStartTime=2.800000
        FadeInEndTime=0.500000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=14.000000,Max=14.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'XEffectMat.Shock.shock_ring_b'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_StoredPowerExplosion.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseDirectionAs=PTDU_Forward
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Y=(Min=0.000000),Z=(Min=0.000000))
        MaxParticles=12
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=20.000000,Max=20.000000)
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.750000,RelativeSize=1.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.250000)
        StartSizeRange=(X=(Min=6.000000,Max=8.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRadialRange=(Min=9.000000,Max=9.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(1)=SpriteEmitter'FX_StoredPowerExplosion.SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.500000
        FadeInEndTime=0.500000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=18.000000,Max=18.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Energy.PurpleSwell'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        InitialDelayRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=SpriteEmitter'FX_StoredPowerExplosion.SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseRevolution=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Y=(Min=0.000000),Z=(Min=0.000000))
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        MaxParticles=24
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=16.000000,Max=16.000000)
        RevolutionsPerSecondRange=(X=(Min=-0.250000,Max=0.250000),Y=(Min=-0.250000,Max=0.250000),Z=(Min=-0.250000,Max=0.250000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=3.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=6.000000,Max=8.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.300000,Max=0.400000)
        InitialDelayRange=(Min=1.000000,Max=1.000000)
        StartVelocityRadialRange=(Min=-128.000000,Max=-128.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(3)=SpriteEmitter'FX_StoredPowerExplosion.SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Y=(Min=0.000000),Z=(Min=0.000000))
        FadeOutStartTime=0.150000
        FadeInEndTime=0.100000
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
        StartSizeRange=(X=(Min=24.000000,Max=36.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'XEffectMat.Shock.shock_flare_a'
        LifetimeRange=(Min=0.250000,Max=0.300000)
        InitialDelayRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(4)=SpriteEmitter'FX_StoredPowerExplosion.SpriteEmitter5'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=128,G=128,R=128))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorMultiplierRange=(Y=(Min=0.000000),Z=(Min=0.000000))
        FadeOutStartTime=3.000000
        FadeInEndTime=0.300000
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
        StartSizeRange=(X=(Min=18.000000,Max=24.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
        LifetimeRange=(Min=1.100000,Max=1.100000)
    End Object
    Emitters(5)=SpriteEmitter'FX_StoredPowerExplosion.SpriteEmitter6'
}
