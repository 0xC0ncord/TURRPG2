//=============================================================================
// FX_WeaponMenuHearts.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_WeaponMenuHearts extends Emitter;

var RPGMenu_Weapons Menu;

simulated function Destroyed()
{
    if(Menu != None)
        Menu.HeartsEffect = None;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        CoordinateSystem=PTCS_Relative
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=-2.000000)
        FadeOutStartTime=1.000000
        FadeInEndTime=0.500000
        MaxParticles=32
        StartLocationOffset=(X=64.000000)
        StartLocationRange=(Y=(Min=-84.000000,Max=64.000000),Z=(Min=48.000000,Max=48.000000))
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        InitialParticlesPerSecond=16.000000
        Texture=Texture'TURRPG2.Effects.loveHearts'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(Y=(Max=8.000000),Z=(Min=-32.000000,Max=-32.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_WeaponMenuHearts.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=192,G=192,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=255))
        ColorMultiplierRange=(Y=(Min=0.600000,Max=0.900000))
        Opacity=0.250000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.300000
        MaxParticles=12
        StartLocationOffset=(X=64.000000)
        StartLocationRange=(Y=(Min=-64.000000,Max=64.000000),Z=(Min=-48.000000,Max=48.000000))
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=192.000000,Max=256.000000))
        InitialParticlesPerSecond=4.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        LifetimeRange=(Min=1.000000,Max=1.500000)
    End Object
    Emitters(1)=SpriteEmitter'FX_WeaponMenuHearts.SpriteEmitter1'

    AutoDestroy=True
    bNoDelete=False
    bHidden=True
}
