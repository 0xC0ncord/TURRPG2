class FX_BlastProjectile_Mega extends FX_BlastProjectile;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter45
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        ColorMultiplierRange=(X=(Max=1.500000))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
        SpinCCWorCW=(X=1.000000)
        SpinsPerSecondRange=(X=(Min=-1.000000,Max=-1.000000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=16.000000,Max=16.000000))
        Texture=Texture'AW-2004Particles.Energy.ElecPanels'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_BlastProjectile_Mega.SpriteEmitter45'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter46
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        SpinCCWorCW=(X=1.000000)
        SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=16.000000,Max=16.000000))
        Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(1)=SpriteEmitter'FX_BlastProjectile_Mega.SpriteEmitter46'

    Begin Object Class=MeshEmitter Name=MeshEmitter4
        StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
        UseParticleColor=True
        UseColorScale=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSizeRange=(X=(Min=0.120000,Max=0.120000),Y=(Min=0.120000,Max=0.120000),Z=(Min=0.120000,Max=0.120000))
        InitialParticlesPerSecond=5000.000000
    End Object
    Emitters(2)=MeshEmitter'FX_BlastProjectile_Mega.MeshEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter47
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.250000)
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=0.750000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=0.250000)
        StartSizeRange=(X=(Min=64.000000,Max=64.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaMuzzleBlue'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(3)=SpriteEmitter'FX_BlastProjectile_Mega.SpriteEmitter47'

    Begin Object Class=TrailEmitter Name=TrailEmitter3
        TrailShadeType=PTTST_Linear
        TrailLocation=PTTL_FollowEmitter
        MaxPointsPerTrail=64
        DistanceThreshold=32.000000
        FadeOut=True
        FadeIn=True
        UseVelocityScale=True
        ColorMultiplierRange=(X=(Min=1.500000,Max=2.000000))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        MaxParticles=12
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=4.000000,Max=4.000000)
        StartSizeRange=(X=(Min=8.000000,Max=12.000000))
        Texture=Texture'AW-2004Particles.Energy.PowerBeam'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRadialRange=(Min=-32.000000,Max=-64.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.500000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=-1.000000,Y=-1.000000,Z=-1.000000))
    End Object
    Emitters(4)=TrailEmitter'FX_BlastProjectile_Mega.TrailEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter48
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UniformSize=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        Opacity=0.250000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.100000
        MaxParticles=16
        StartSizeRange=(X=(Min=32.000000,Max=32.000000))
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(5)=SpriteEmitter'FX_BlastProjectile_Mega.SpriteEmitter48'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter49
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=32.000000,Max=32.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(6)=SpriteEmitter'FX_BlastProjectile_Mega.SpriteEmitter49'
}
