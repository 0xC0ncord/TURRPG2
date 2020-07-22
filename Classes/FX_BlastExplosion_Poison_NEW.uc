//=============================================================================
// FX_BlastExplosion_Poison_NEW.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_BlastExplosion_Poison_NEW extends FX_BlastExplosion_NEW;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter98
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=0.050000
        MaxParticles=1
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=256.000000,Max=256.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.LargeSpot'
        LifetimeRange=(Min=0.200000,Max=0.200000)
    End Object
    Emitters(0)=SpriteEmitter'FX_BlastExplosion_Poison_NEW.SpriteEmitter98'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter99
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        ColorMultiplierRange=(Z=(Min=0.000000))
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=256
        MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Complex.ParticleObjectTest2'
        MeshSpawning=PTMS_Random
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
        LifetimeRange=(Min=0.400000,Max=0.500000)
        StartVelocityRadialRange=(Min=-1536.000000,Max=-2048.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(1)=SpriteEmitter'FX_BlastExplosion_Poison_NEW.SpriteEmitter99'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter100
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        ColorMultiplierRange=(Z=(Min=0.000000))
        FadeOutStartTime=0.300000
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=6.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=192.000000,Max=192.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Fire.SmallBang'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=SpriteEmitter'FX_BlastExplosion_Poison_NEW.SpriteEmitter100'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter101
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        ColorMultiplierRange=(Z=(Min=0.000000))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.050000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=4.000000)
        StartSizeRange=(X=(Min=512.000000,Max=512.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
        LifetimeRange=(Min=0.200000,Max=0.200000)
    End Object
    Emitters(3)=SpriteEmitter'FX_BlastExplosion_Poison_NEW.SpriteEmitter101'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter102
        UseDirectionAs=PTDU_Forward
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=255,R=128))
        ColorMultiplierRange=(Z=(Min=0.000000))
        FadeOutStartTime=0.200000
        FadeInEndTime=0.050000
        MaxParticles=128
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=32.000000,Max=32.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRadialRange=(Min=-2048.000000,Max=-2048.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.200000))
    End Object
    Emitters(4)=SpriteEmitter'FX_BlastExplosion_Poison_NEW.SpriteEmitter102'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter103
        UseDirectionAs=PTDU_Forward
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        ColorScale(0)=(Color=(B=64,G=255,R=64))
        ColorScale(1)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
        ColorMultiplierRange=(Z=(Min=0.000000))
        Opacity=0.500000
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=256
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=1024.000000,Max=1024.000000)
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=192.000000,Max=256.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRadialRange=(Min=-2048.000000,Max=-2048.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000)
    End Object
    Emitters(5)=SpriteEmitter'FX_BlastExplosion_Poison_NEW.SpriteEmitter103'
}
