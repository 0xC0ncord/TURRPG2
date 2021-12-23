//=============================================================================
// FX_Metamorphosis.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Metamorphosis extends RPGEmitter;

simulated function PostNetBeginPlay()
{
    local float HeightMultiplier, RadiusMultiplier;

    if(Level.NetMode == NM_DedicatedServer)
        return;

    PlaySound(sound'Metamorphosis', SLOT_Misc, 255,, 256);

    if(Owner == None)
        return;

    HeightMultiplier = Owner.CollisionHeight / 25;
    RadiusMultiplier = Owner.CollisionRadius / 44;

    Emitters[0].StartSizeRange.X.Min *= RadiusMultiplier;
    Emitters[0].StartSizeRange.X.Max *= RadiusMultiplier;

    Emitters[1].StartLocationPolarRange.Z.Min *= RadiusMultiplier;
    Emitters[1].StartLocationPolarRange.Z.Max *= RadiusMultiplier;
    Emitters[1].StartLocationOffset.Z *= HeightMultiplier;

    Emitters[2].StartSizeRange.X.Min *= RadiusMultiplier;
    Emitters[2].StartSizeRange.X.Max *= RadiusMultiplier;
    Emitters[2].StartSizeRange.Y.Min *= RadiusMultiplier;
    Emitters[2].StartSizeRange.Y.Max *= RadiusMultiplier;
    Emitters[2].StartSizeRange.Z.Min *= HeightMultiplier;
    Emitters[2].StartSizeRange.Z.Max *= HeightMultiplier;

    Emitters[3].StartLocationPolarRange.Z.Min *= RadiusMultiplier;
    Emitters[3].StartLocationPolarRange.Z.Max *= RadiusMultiplier;
    Emitters[3].StartLocationRange.Z.Min  *= HeightMultiplier;
    Emitters[3].StartLocationRange.Z.Max  *= HeightMultiplier;

    Emitters[4].StartSizeRange.X.Min *= RadiusMultiplier;
    Emitters[4].StartSizeRange.X.Max *= RadiusMultiplier;

    if(Owner.Physics != PHYS_Walking)
    {
        Emitters[5].Disabled = true;
        return;
    }

    Emitters[5].StartSizeRange.X.Min *= RadiusMultiplier;
    Emitters[5].StartSizeRange.X.Max *= RadiusMultiplier;
    Emitters[5].StartLocationOffset.Z *= HeightMultiplier;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter33
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.050000
        FadeInEndTime=0.020000
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=96.000000,Max=96.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=0.300000,Max=0.300000)
    End Object
    Emitters(0)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter33'

    Begin Object Class=TrailEmitter Name=TrailEmitter3
        TrailShadeType=PTTST_Linear
        DistanceThreshold=4.000000
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseRevolution=True
        ColorMultiplierRange=(X=(Min=0.700000))
        FadeOutStartTime=0.400000
        FadeInEndTime=0.200000
        MaxParticles=20
        StartLocationOffset=(Z=44.000000)
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(X=(Min=-32768.000000,Max=32768.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=64.000000,Max=64.000000))
        RevolutionsPerSecondRange=(Z=(Min=0.800000,Max=1.200000))
        StartSizeRange=(X=(Min=4.000000,Max=12.000000))
        Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
        LifetimeRange=(Min=0.600000,Max=0.600000)
        StartVelocityRange=(Z=(Min=-128.000000,Max=-128.000000))
        StartVelocityRadialRange=(Min=24.000000,Max=32.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(1)=TrailEmitter'FX_Metamorphosis.TrailEmitter3'

    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockTankEffectRing'
        UseParticleColor=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        MaxParticles=1
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=MeshEmitter'FX_Metamorphosis.MeshEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter37
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseRevolution=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.800000))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.200000
        MaxParticles=48
        StartLocationRange=(Z=(Min=-44.000000,Max=44.000000))
        StartLocationShape=PTLS_All
        StartLocationPolarRange=(X=(Min=-32768.000000,Max=32768.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=22.000000,Max=22.000000))
        RevolutionsPerSecondRange=(Z=(Min=0.500000,Max=1.000000))
        SpinsPerSecondRange=(X=(Max=0.010000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
        LifetimeRange=(Min=0.700000,Max=0.800000)
        StartVelocityRadialRange=(Min=-64.000000,Max=-64.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=3.000000,Y=3.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.200000,RelativeVelocity=(X=5.000000,Y=5.000000,Z=0.300000))
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=8.000000,Y=8.000000))
        VelocityScale(3)=(RelativeTime=1.000000,RelativeVelocity=(X=12.000000,Y=12.000000))
    End Object
    Emitters(3)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter37'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter39
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.600000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Min=1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=64.000000,Max=64.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(4)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter39'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter40
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartLocationOffset=(Z=-44.000000)
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=48.000000,Max=48.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Smoke.Maelstrom01aw'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(5)=SpriteEmitter'FX_Metamorphosis.SpriteEmitter40'

    SoundVolume=255
    LifeSpan=4.000000
}
