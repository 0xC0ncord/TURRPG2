//=============================================================================
// FX_MatrixTrail.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_MatrixTrail extends Emitter;

simulated event PostNetBeginPlay()
{
    SetTimer(0.5, true);
}

simulated function Timer()
{
    local Projectile P;

    P = Projectile(Owner);
    if(P == None)
    {
        Kill();
        SetTimer(0, false);
    }
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=0.250000,Color=(B=153,G=255,R=155))
        ColorScale(2)=(RelativeTime=0.500000,Color=(G=255))
        ColorScale(3)=(RelativeTime=0.750000,Color=(B=153,G=255,R=155))
        MaxParticles=100
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=1.000000,Max=4.000000)
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Min=0.550000,Max=0.450000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.400000)
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
        ParticlesPerSecond=5.000000
        InitialParticlesPerSecond=10.000000
        Texture=Texture'TURRPG2.Effects.AlienChars'
        TextureUSubdivisions=8
        TextureVSubdivisions=8
        LifetimeRange=(Min=1.600000,Max=1.700000)
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    AutoDestroy=True
    bNoDelete=False
    bNetTemporary=True
    Physics=PHYS_Trailer
    RemoteRole=ROLE_DumbProxy
    Style=STY_Additive
    bDirectional=True
}
