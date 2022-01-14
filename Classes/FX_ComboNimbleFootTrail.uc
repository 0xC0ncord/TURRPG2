//=============================================================================
// FX_ComboNimbleFootTrail.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboNimbleFootTrail extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter23
        UseDirectionAs=PTDU_Right
        FadeOut=True
        FadeIn=True
        UseSizeScale=True
        UniformSize=True
        ScaleSizeXByVelocity=True
        ColorMultiplierRange=(X=(Min=0.900000))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.050000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartLocationOffset=(X=16.000000)
        StartSizeRange=(X=(Min=10.000000,Max=12.000000))
        ScaleSizeByVelocityMultiplier=(X=2.000000)
        Texture=Texture'AW-2004Particles.Weapons.SoftFade'
        LifetimeRange=(Min=0.150000,Max=0.200000)
        StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboNimbleFootTrail.SpriteEmitter23'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter24
        FadeOut=True
        FadeIn=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.600000))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=6
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=1.000000,Max=2.000000))
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.250000,Max=0.300000)
        StartVelocityRange=(X=(Min=128.000000,Max=192.000000),Y=(Min=-16.000000,Max=16.000000),Z=(Min=-16.000000,Max=16.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboNimbleFootTrail.SpriteEmitter24'

	bOwnerNoSee=True
}