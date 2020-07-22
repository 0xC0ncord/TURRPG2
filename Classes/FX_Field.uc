//=============================================================================
// FX_Field.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Field extends Emitter;

var RPGFieldGenerator FieldGenerator;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        FieldGenerator;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(Role == ROLE_Authority)
        FieldGenerator = RPGFieldGenerator(Owner);
}

simulated function PostNetBeginPlay()
{
    if(FieldGenerator != None)
        FieldGenerator.ModifyEffect(Self);
    PlayOwnedSound(sound'BTranslocatorModuleRegeneration',SLOT_Misc,255,,32);
}

simulated function Tick(float dt)
{
    if(FieldGenerator == None || FieldGenerator.Health <= 0)
        Destroy();
}

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'PlasmaSphere'
        UseParticleColor=True
        UseColorScale=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        Opacity=0.250000
        MaxParticles=1
        StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.100000,Max=0.100000)
        InitialDelayRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(0)=MeshEmitter'FX_Field.MeshEmitter0'

    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'PlasmaSphere'
        UseParticleColor=True
        UseColorScale=True
        FadeIn=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        Opacity=0.250000
        FadeInEndTime=0.500000
        MaxParticles=1
        StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(1)=MeshEmitter'FX_Field.MeshEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        Opacity=0.500000
        FadeOutStartTime=0.500000
        FadeInEndTime=0.500000
        MaxParticles=8
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=184.000000,Max=184.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=4.000000,Max=8.000000))
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        InitialDelayRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=SpriteEmitter'FX_Field.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        Opacity=0.500000
        FadeOutStartTime=0.200000
        FadeInEndTime=0.200000
        MaxParticles=4
        StartLocationOffset=(Z=-128.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        Texture=Texture'AW-2004Particles.Fire.BlastMark'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(3)=SpriteEmitter'FX_Field.SpriteEmitter1'

    AutoDestroy=True
    bNoDelete=False
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=True
    Skins(0)=FinalBlend'WhiteShieldFinal'
}
