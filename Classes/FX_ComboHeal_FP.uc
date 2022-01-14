//=============================================================================
// FX_ComboHeal_FP.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboHeal_FP extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        RespawnDeadParticles=False
        UseRevolution=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Opacity=0.500000
        FadeOutStartTime=0.150000
        CoordinateSystem=PTCS_Relative
        MaxParticles=80
        StartLocationOffset=(Z=-20.000000)
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=24.000000,Max=48.000000)
        RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.500000)
        SizeScale(1)=(RelativeTime=0.750000,RelativeSize=2.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=1.000000,Max=2.000000))
        InitialParticlesPerSecond=80.000000
        Texture=Texture'TURRPG2.Effects.UC2_FX_Flares_05'
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRange=(Z=(Min=96.000000,Max=160.000000))
        StartVelocityRadialRange=(Min=48.000000,Max=48.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboHeal_FP.SpriteEmitter0'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
    bOnlyOwnerSee=True
    bOnlyRelevantToOwner=True
}
