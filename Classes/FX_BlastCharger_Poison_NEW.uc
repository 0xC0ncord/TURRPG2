class FX_BlastCharger_Poison_NEW extends FX_BlastCharger_NEW;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter36
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=4
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=2.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=64.000000,Max=64.000000))
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_BlastCharger_Poison_NEW.SpriteEmitter36'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter37
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UniformSize=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=256
        MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere2'
        MeshSpawning=PTMS_Linear
        StartSizeRange=(X=(Min=4.000000,Max=8.000000))
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRadialRange=(Min=128.000000,Max=128.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(1)=SpriteEmitter'FX_BlastCharger_Poison_NEW.SpriteEmitter37'

    Begin Object Class=BeamEmitter Name=BeamEmitter2
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        FadeOutStartTime=0.050000
        FadeInEndTime=0.050000
        MaxParticles=32
        StartSizeRange=(X=(Min=24.000000,Max=32.000000))
        Texture=Texture'AW-2k4XP.Cicada.MissileTrail1a'
        LifetimeRange=(Min=0.100000,Max=0.200000)
        StartVelocityRange=(X=(Min=-384.000000,Max=384.000000),Y=(Min=-384.000000,Max=384.000000),Z=(Min=-384.000000,Max=384.000000))
    End Object
    Emitters(2)=BeamEmitter'FX_BlastCharger_Poison_NEW.BeamEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter38
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorMultiplierRange=(Z=(Min=0.000000,Max=0.000000))
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=32.000000,Max=48.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2k4XP.Weapons.ShockTankEffectCore'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(3)=SpriteEmitter'FX_BlastCharger_Poison_NEW.SpriteEmitter38'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter39
        UseDirectionAs=PTDU_Forward
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        FadeOutStartTime=1.900000
        FadeInEndTime=0.100000
        MaxParticles=64
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=4.000000,Max=4.000000)
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=16.000000,Max=16.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRadialRange=(Min=-192.000000,Max=-192.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.150000,RelativeVelocity=(X=0.020000,Y=0.020000,Z=0.020000))
        VelocityScale(2)=(RelativeTime=0.700000,RelativeVelocity=(X=0.010000,Y=0.010000,Z=0.010000))
    End Object
    Emitters(4)=SpriteEmitter'FX_BlastCharger_Poison_NEW.SpriteEmitter39'
}
