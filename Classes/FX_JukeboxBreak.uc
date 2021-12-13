//=============================================================================
// FX_JukeboxBreak.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_JukeboxBreak extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseCollision=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        RespawnDeadParticles=False
        Acceleration=(Z=-900.000000)
        DampingFactorRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
        MaxParticles=64
        StartLocationRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=-32.000000,Max=32.000000))
        StartSizeRange=(X=(Min=4.000000,Max=4.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Regular
        Texture=Texture'JukeboxBottom'
        TextureUSubdivisions=8
        TextureVSubdivisions=8
        StartVelocityRange=(X=(Min=-64.000000,Max=64.000000),Y=(Min=-64.000000,Max=64.000000),Z=(Max=384.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_JukeboxBreak.SpriteEmitter0'

    AutoDestroy=True
    bNoDelete=False
}
