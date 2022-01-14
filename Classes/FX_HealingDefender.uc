//=============================================================================
// FX_HealingDefender.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_HealingDefender extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter24
        UseDirectionAs=PTDU_Forward
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255))
        FadeOutStartTime=0.050000
        FadeInEndTime=0.050000
        CoordinateSystem=PTCS_Relative
        MaxParticles=512
        MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
        MeshSpawning=PTMS_Linear
        MeshScaleRange=(X=(Min=0.800000,Max=0.800000))
        StartSizeRange=(X=(Min=8.000000,Max=12.000000))
        InitialParticlesPerSecond=512.000000
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=0.100000,Max=0.100000)
        StartVelocityRadialRange=(Min=-32.000000,Max=-32.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(0)=SpriteEmitter'FX_HealingDefender.SpriteEmitter24'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
