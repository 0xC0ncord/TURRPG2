//=============================================================================
// FX_ComboIronSpirit_FP.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboIronSpirit_FP extends RPGEmitter;

defaultproperties
{
    Begin Object Class=TrailEmitter Name=TrailEmitter1
        TrailShadeType=PTTST_Linear
        UseCrossedSheets=True
        FadeOut=True
        FadeIn=True
        UseRevolution=True
        ColorMultiplierRange=(Z=(Min=0.600000,Max=0.900000))
        FadeOutStartTime=0.800000
        FadeInEndTime=0.200000
        MaxParticles=8
        StartLocationOffset=(Z=-44.000000)
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(X=(Min=-32768.000000,Max=32768.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=22.000000,Max=22.000000))
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=2.000000))
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(Z=(Min=88.000000,Max=88.000000))
    End Object
    Emitters(1)=TrailEmitter'FX_ComboIronSpirit_FP.TrailEmitter1'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
    bOnlyOwnerSee=True
    bOnlyRelevantToOwner=True
}
