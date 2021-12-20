//=============================================================================
// FX_Shock.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Shock extends RPGEmitter;

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(Owner != None)
    {
        SpriteEmitter(Emitters[0]).StartLocationRange.X.Min = Owner.CollisionRadius * -1;
        SpriteEmitter(Emitters[0]).StartLocationRange.X.Max = Owner.CollisionRadius;
        SpriteEmitter(Emitters[0]).StartLocationRange.Y.Min = Owner.CollisionRadius * -1;
        SpriteEmitter(Emitters[0]).StartLocationRange.Y.Max = Owner.CollisionRadius;
        SpriteEmitter(Emitters[0]).StartLocationRange.Z.Min = Owner.CollisionHeight * -1;
        SpriteEmitter(Emitters[0]).StartLocationRange.Z.Max = Owner.CollisionHeight;

        BeamEmitter(Emitters[1]).StartLocationRange.Z.Min = Owner.CollisionHeight * -1;
        BeamEmitter(Emitters[1]).StartLocationRange.Z.Max = Owner.CollisionHeight;
        BeamEmitter(Emitters[1]).StartVelocityRange.Z.Min = Owner.CollisionRadius + 384;
        BeamEmitter(Emitters[1]).StartVelocityRange.Z.Max = (Owner.CollisionRadius + 384) * -1;
        BeamEmitter(Emitters[1]).StartVelocityRange.X.Max = Owner.CollisionRadius + 384;
        BeamEmitter(Emitters[1]).StartVelocityRange.X.Min = (Owner.CollisionRadius + 384) * -1;
        BeamEmitter(Emitters[1]).StartVelocityRange.Y.Min = (Owner.CollisionRadius + 384) * -1;
        BeamEmitter(Emitters[1]).StartVelocityRange.Y.Max = Owner.CollisionRadius + 384;
    }
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter38
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        ColorScaleRepeats=2.000000
        ColorMultiplierRange=(X=(Min=0.500000,Max=1.500000))
        CoordinateSystem=PTCS_Relative
        MaxParticles=32
        StartLocationRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=-64.000000,Max=64.000000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=8.000000,Max=15.000000))
        InitialParticlesPerSecond=32.000000
        Texture=Texture'XEffects.LightningChargeT'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(Z=(Min=100.000000,Max=100.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_Shock.SpriteEmitter38'

    Begin Object Class=BeamEmitter Name=BeamEmitter2
        BeamTextureUScale=0.200000
        BeamTextureVScale=0.500000
        LowFrequencyNoiseRange=(X=(Min=-16.000000,Max=16.000000),Y=(Min=-16.000000,Max=16.000000),Z=(Min=-16.000000,Max=16.000000))
        UseColorScale=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        ColorScaleRepeats=1.000000
        ColorMultiplierRange=(X=(Min=0.500000,Max=1.500000))
        MaxParticles=32
        StartLocationRange=(Z=(Min=-64.000000,Max=64.000000))
        StartSizeRange=(X=(Min=5.000000,Max=15.000000))
        InitialParticlesPerSecond=32.000000
        Texture=Texture'XEffects.Skins.LightningBoltT'
        LifetimeRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(X=(Min=-512.000000,Max=512.000000),Y=(Min=-512.000000,Max=512.000000),Z=(Min=-512.000000,Max=512.000000))
    End Object
    Emitters(1)=BeamEmitter'FX_Shock.BeamEmitter2'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
