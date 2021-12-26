class FX_ComboEthereal_FP extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UseRevolution=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        UseVelocityScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.400000,Color=(B=255,G=128))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255))
        ColorMultiplierRange=(X=(Min=0.800000))
        FadeOutStartTime=0.600000
        FadeInEndTime=0.200000
        StartLocationRange=(Z=(Min=-32.000000,Max=32.000000))
        StartLocationShape=PTLS_All
        StartLocationPolarRange=(X=(Min=-32768.000000,Max=32768.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=24.000000,Max=32.000000))
        RevolutionsPerSecondRange=(Z=(Min=0.800000,Max=1.500000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        Texture=Texture'EpicParticles.Flares.HotSpot'
        LifetimeRange=(Min=0.800000,Max=1.200000)
        StartVelocityRadialRange=(Min=-12.000000,Max=-16.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=12.000000,Y=12.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.300000,RelativeVelocity=(X=2.000000,Y=2.000000,Z=1.000000))
        VelocityScale(2)=(RelativeTime=0.700000,RelativeVelocity=(X=3.000000,Y=3.000000,Z=1.000000))
        VelocityScale(3)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboEthereal_FP.SpriteEmitter9'

	Physics=PHYS_Trailer
	bTrailerAllowRotation=True
	bOnlyOwnerSee=True
	bOnlyRelevantToOwner=True
}