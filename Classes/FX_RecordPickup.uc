//=============================================================================
// FX_RecordPickup.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_RecordPickup extends Emitter;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter1
        Disabled=True
        StaticMesh=StaticMesh'MusicDisc'
        SpinParticles=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Min=0.125000,Max=0.125000))
        StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
        InitialParticlesPerSecond=5000.000000
        StartVelocityRange=(Z=(Min=-24.000000,Max=-24.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.250000)
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(Z=-1.000000))
        VelocityScale(3)=(RelativeTime=0.750000)
        VelocityScale(4)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(0)=MeshEmitter'FX_RecordPickup.MeshEmitter1'

    AutoDestroy=True
    bNoDelete=False
    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
