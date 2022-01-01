//=============================================================================
// FX_Burn.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Burn extends RPGEmitter;

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if(Level.NetMode != NM_DedicatedServer && Owner != None)
    {
        SpriteEmitter(Emitters[0]).SphereRadiusRange.Max *= Owner.CollisionHeight / 44;
        SpriteEmitter(Emitters[0]).StartSizeRange.X.Min *= Owner.CollisionHeight / 44;
        SpriteEmitter(Emitters[0]).StartSizeRange.X.Max *= Owner.CollisionHeight / 44;
        SpriteEmitter(Emitters[0]).StartVelocityRange.Z.Min *= Owner.CollisionHeight / 44;
        SpriteEmitter(Emitters[0]).StartVelocityRange.Z.Max *= Owner.CollisionHeight / 44;
    }
    SetTimer(1.5, false);
}

simulated function Tick(float DeltaTime)
{
    if(Pawn(Owner) == None || Pawn(Owner).Health <= 0)
    {
        Kill();
        Disable('Tick');
    }
}

simulated function Timer()
{
    Kill();
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        UseRandomSubdivision=True
        FadeOutStartTime=0.050000
        FadeInEndTime=0.050000
        MaxParticles=8
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=32.000000)
        StartSpinRange=(X=(Min=0.350000,Max=0.450000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=16.000000,Max=32.000000))
        Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(Z=(Min=256.000000,Max=384.000000))
        StartVelocityRadialRange=(Min=48.000000,Max=64.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_Burn.SpriteEmitter0'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
