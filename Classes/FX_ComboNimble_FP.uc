//=============================================================================
// FX_ComboNimble_FP.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboNimble_FP extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter22
        FadeOut=True
        FadeIn=True
        UseRevolution=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        UseVelocityScale=True
        ColorMultiplierRange=(X=(Min=0.500000))
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        StartLocationRange=(Z=(Min=-32.000000,Max=32.000000))
        StartLocationShape=PTLS_All
        StartLocationPolarRange=(X=(Min=-32768.000000,Max=32768.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=12.000000,Max=16.000000))
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=3.000000,Max=4.000000))
        Texture=Texture'EpicParticles.Flares.OutSpark02aw'
        LifetimeRange=(Min=0.700000,Max=0.800000)
        StartVelocityRadialRange=(Min=-96.000000,Max=-128.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=3.000000,Y=3.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.300000,RelativeVelocity=(X=2.000000,Y=2.000000,Z=0.500000))
        VelocityScale(2)=(RelativeTime=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboNimble_FP.SpriteEmitter22'

	Physics=PHYS_Trailer
	bTrailerAllowRotation=True
	bOnlyOwnerSee=True
	bOnlyRelevantToOwner=True
}