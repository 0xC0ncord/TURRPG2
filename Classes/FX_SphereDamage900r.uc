class FX_SphereDamage900r extends FX_SphereArtifact;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        RespawnDeadParticles=False
        UseDirectionAs=PTDU_Forward
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(B=255,R=128))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
        FadeOutStartTime=0.250000
        FadeInEndTime=0.250000
        MaxParticles=32
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=900.000000,Max=900.000000)
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRadialRange=(Min=-1.000000,Max=-1.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_SphereDamage900r.SpriteEmitter0'

    Begin Object Class=MeshEmitter Name=MeshEmitter0
        RespawnDeadParticles=False
        StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
        UseParticleColor=True
        UseColorScale=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
        Opacity=0.500000
        MaxParticles=1
        StartSizeRange=(X=(Min=14.000000,Max=14.000000),Y=(Min=14.000000,Max=14.000000),Z=(Min=14.000000,Max=14.000000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(1)=MeshEmitter'FX_SphereDamage900r.MeshEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        RespawnDeadParticles=False
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorScale(0)=(Color=(B=255,R=128))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
        Opacity=0.500000
        FadeOutStartTime=0.250000
        FadeInEndTime=0.250000
        MaxParticles=2
        SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=1900.000000,Max=1900.000000))
        Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=SpriteEmitter'FX_SphereDamage900r.SpriteEmitter1'

}
