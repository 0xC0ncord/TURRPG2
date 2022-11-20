//=============================================================================
// FX_MoteActive_Gold_Triple.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_MoteActive_Gold_Triple extends FX_MoteActive_Triple;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter47
        UseRevolution=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=32.000000,Z=-8.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=None
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.250000)
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(Z=-1.000000))
        VelocityScale(3)=(RelativeTime=0.750000)
        VelocityScale(4)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter47'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter59
        UseRevolution=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=-16.000000,Y=-28.000000,Z=-8.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=None
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(Z=(Min=-64.000000,Max=-64.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.250000)
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(Z=-1.000000))
        VelocityScale(3)=(RelativeTime=0.750000)
        VelocityScale(4)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(4)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter59'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter65
        UseRevolution=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=-16.000000,Y=28.000000,Z=-8.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=None
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.250000)
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(Z=-1.000000))
        VelocityScale(3)=(RelativeTime=0.750000)
        VelocityScale(4)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(8)=SpriteEmitter'FX_MoteActive_Gold_Triple.SpriteEmitter65'

}

