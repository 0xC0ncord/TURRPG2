//=============================================================================
// FX_ComboHolographDummy.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboHolographDummy extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.600000))
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        MaxParticles=3
        StartLocationOffset=(Z=-60.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
        StartSizeRange=(X=(Min=16.000000,Max=16.000000))
        Texture=Texture'XEffectMat.Shock.shock_ring_b'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(Z=(Min=32.000000,Max=32.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboHolographDummy.SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.600000))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=6
        StartLocationOffset=(Z=-60.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=3.000000,Max=4.000000))
        Texture=Texture'XEffectMat.Shock.shock_sparkle'
        LifetimeRange=(Min=0.350000,Max=0.400000)
        StartVelocityRange=(X=(Min=-192.000000,Max=192.000000),Y=(Min=-192.000000,Max=192.000000),Z=(Min=96.000000,Max=128.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboHolographDummy.SpriteEmitter5'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
        UseDirectionAs=PTDU_Up
        UseColorScale=True
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=192,R=128))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=192,R=128))
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.650000))
        MaxParticles=2
        StartLocationOffset=(Z=-12.000000)
        StartSizeRange=(X=(Min=48.000000,Max=64.000000))
        Texture=Texture'XEffectMat.Shock.shock_flash'
        LifetimeRange=(Min=0.100000,Max=0.100000)
        StartVelocityRange=(Z=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(2)=SpriteEmitter'FX_ComboHolographDummy.SpriteEmitter6'

    AutoDestroy=True
    bNoDelete=False
}
