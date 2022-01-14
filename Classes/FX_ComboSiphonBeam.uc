//=============================================================================
// FX_ComboSiphonBeam.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboSiphonBeam extends RPGEmitter;

simulated function AimAt(Pawn Other)
{
    local float Dist;

    Dist = VSize(Other.Location - Location);

    Emitters[0].StartLocationRange.X.Max = Dist;
    BeamEmitter(Emitters[1]).BeamDistanceRange.Min = Dist;
    BeamEmitter(Emitters[1]).BeamDistanceRange.Max = Dist;

    SetRotation(rotator(Other.Location - Location));
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter17
        FadeOut=True
        FadeIn=True
        UniformSize=True
        ColorMultiplierRange=(X=(Min=0.900000),Z=(Min=0.600000))
        FadeOutStartTime=0.200000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=16
        StartLocationRange=(X=(Max=512.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Min=-4.000000,Max=4.000000))
        SphereRadiusRange=(Max=32.000000)
        StartSizeRange=(X=(Min=8.000000,Max=12.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.300000,Max=0.400000)
        StartVelocityRange=(X=(Min=-6.000000,Max=6.000000),Y=(Min=-6.000000,Max=6.000000),Z=(Min=-6.000000,Max=6.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboSiphonBeam.SpriteEmitter17'

    Begin Object Class=BeamEmitter Name=BeamEmitter0
        BeamDistanceRange=(Min=512.000000,Max=512.000000)
        DetermineEndPointBy=PTEP_Distance
        LowFrequencyNoiseRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
        HighFrequencyNoiseRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
        FadeOut=True
        FadeIn=True
        ColorMultiplierRange=(X=(Min=0.900000),Z=(Min=0.700000))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartSizeRange=(X=(Min=4.000000,Max=6.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'VMParticleTextures.LeviathanParticleEffects.LEVmainPartBeam'
        LifetimeRange=(Min=0.300000,Max=0.400000)
        StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(1)=BeamEmitter'FX_ComboSiphonBeam.BeamEmitter0'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
