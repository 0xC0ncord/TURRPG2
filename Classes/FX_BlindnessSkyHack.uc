//=============================================================================
// FX_BlindnessSkyHack.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//hack to fix sky showing up past distance fog for blindness effect
class FX_BlindnessSkyHack extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UniformSize=True
        AutomaticInitialSpawning=False
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=512.000000)
        StartSizeRange=(X=(Min=1000.000000,Max=1000.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Regular
        Texture=Texture'Engine.BlackTexture'
        LifetimeRange=(Min=0.100000,Max=0.100000)
    End Object
    Emitters(0)=SpriteEmitter'FX_BlindnessSkyHack.SpriteEmitter0'

    bNoDelete=False
}
