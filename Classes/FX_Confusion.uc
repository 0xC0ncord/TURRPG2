//=============================================================================
// FX_Confusion.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Confusion extends RPGEmitter;

simulated function PostNetBeginPlay()
{
	if(Owner == None)
		return;
	
	Emitters[0].StartLocationOffset.Z = (Owner.CollisionHeight * 0.5) - 12;
	Emitters[0].SphereRadiusRange.Max = Owner.CollisionRadius * 0.24;
	Emitters[0].SphereRadiusRange.Min = Emitters[0].SphereRadiusRange.Max * 0.75;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(Z=(Min=0.500000))
        Opacity=0.750000
        FadeOutStartTime=0.030000
        FadeInEndTime=0.020000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=8.000000,Max=12.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=4.000000,Max=6.000000))
        Texture=Texture'AW-2004Particles.Fire.SmallBang'
        LifetimeRange=(Min=0.080000,Max=0.100000)
    End Object
    Emitters(0)=SpriteEmitter'FX_Confusion.SpriteEmitter3'

}