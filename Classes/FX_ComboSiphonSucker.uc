//=============================================================================
// FX_ComboSiphonSucker.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_ComboSiphonSucker extends RPGEmitter;

var Pawn AimTarget;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        AimTarget;
}

simulated function Tick(float dt)
{
    local float dist;

    if(AimTarget == None || Pawn(Owner) == None || Pawn(Owner).Health <= 0)
    {
        Die();
        Disable('Tick');
        return;
    }

    SetRotation(rotator(AimTarget.Location - Location));

    dist = VSize(AimTarget.Location - Location);
    Emitters[0].StartVelocityRange.X.Min = dist;
    Emitters[0].StartVelocityRange.X.Max = dist;
    Emitters[1].StartVelocityRange.X.Min = dist;
    Emitters[1].StartVelocityRange.X.Max = dist;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        UseVelocityScale=True
        ColorMultiplierRange=(X=(Min=0.800000),Y=(Min=0.900000),Z=(Min=0.800000))
        FadeOutStartTime=0.900000
        FadeInEndTime=0.100000
        MaxParticles=8
        CoordinateSystem=PTCS_Relative
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=1.000000,Max=2.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=6.000000,Max=8.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=512.000000,Max=512.000000),Y=(Min=-128.000000,Max=128.000000),Z=(Min=-128.000000,Max=128.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=-1.000000,Z=-1.000000))
    End Object
    Emitters(0)=SpriteEmitter'FX_ComboSiphonSucker.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseDirectionAs=PTDU_Up
        FadeOut=True
        FadeIn=True
        UniformSize=True
        ScaleSizeYByVelocity=True
        UseVelocityScale=True
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.000000,Max=0.000000))
        FadeOutStartTime=0.900000
        FadeInEndTime=0.100000
        MaxParticles=6
        CoordinateSystem=PTCS_Relative
        StartSizeRange=(X=(Min=4.000000,Max=6.000000))
        ScaleSizeByVelocityMultiplier=(Y=0.060000)
        DrawStyle=PTDS_Darken
        Texture=Texture'AW-2004Particles.Weapons.HardSpot'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=512.000000,Max=512.000000),Y=(Min=-72.000000,Max=72.000000),Z=(Min=-72.000000,Max=72.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=-1.000000,Z=-1.000000))
    End Object
    Emitters(1)=SpriteEmitter'FX_ComboSiphonSucker.SpriteEmitter1'

    // Begin Object Class=TrailEmitter Name=TrailEmitter2
    //     TrailShadeType=PTTST_Linear
    //     MaxPointsPerTrail=60
    //     DistanceThreshold=3.000000
    //     FadeOut=True
    //     FadeIn=True
    //     UseVelocityScale=True
    //     ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.200000))
    //     FadeOutStartTime=0.900000
    //     FadeInEndTime=0.100000
    //     MaxParticles=3
    //     StartLocationOffset=(X=512.000000)
    //     StartLocationShape=PTLS_Sphere
    //     SphereRadiusRange=(Min=1.000000,Max=2.000000)
    //     StartSizeRange=(X=(Min=2.000000,Max=3.000000))
    //     DrawStyle=PTDS_AlphaBlend
    //     Texture=Texture'AW-2004Particles.Weapons.TrailBlura'
    //     LifetimeRange=(Min=1.000000,Max=1.000000)
    //     StartVelocityRange=(X=(Min=512.000000,Max=512.000000),Y=(Min=-96.000000,Max=96.000000),Z=(Min=-96.000000,Max=96.000000))
    //     VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
    //     VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=-1.000000,Z=-1.000000))
    // End Object
    // Emitters(2)=TrailEmitter'FX_ComboSiphonSucker.TrailEmitter2'

    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
