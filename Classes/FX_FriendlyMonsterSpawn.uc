//=============================================================================
// FX_FriendlyMonsterSpawn.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_FriendlyMonsterSpawn extends Emitter;

var class<Pawn> PawnClass;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        PawnClass;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(Role == ROLE_Authority)
        SetTimer(2.0,false);
}

simulated function Tick(float DeltaTime)
{
    if(PawnClass != None && Level.NetMode != NM_DedicatedServer)
    {
        UpdateEffects(PawnClass);
        Disable('Tick');
    }
}

simulated function UpdateEffects(class<Pawn> Other)
{
    SetDrawScale(Other.default.CollisionRadius / CollisionRadius);

    //center initial flares
    Emitters[0].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
    Emitters[0].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);
    Emitters[1].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
    Emitters[1].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);

    //spinny thingy base
    Emitters[2].StartLocationOffset.Y = 64 * (Other.default.CollisionHeight / 44);
    Emitters[2].StartLocationOffset.Y = 64 * (Other.default.CollisionHeight / 44);
    Emitters[2].StartLocationPolarRange.Z.Min = 32 * (Other.default.CollisionRadius / 25);
    Emitters[2].StartLocationPolarRange.Z.Max = 32 * (Other.default.CollisionRadius / 25);
    Emitters[2].StartVelocityRange.Y.Min = -64 * (Other.default.CollisionHeight / 44);
    Emitters[2].StartVelocityRange.Y.Max = -64 * (Other.default.CollisionHeight / 44);

    //spinny thingy trail
    Emitters[3].MaxActiveParticles *= DrawScale;
    Emitters[3].Particles.Length = Emitters[3].MaxActiveParticles;

    //blue rising discs
    Emitters[4].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
    Emitters[4].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
    Emitters[4].StartSizeRange.X.Min = 40 * (Other.default.CollisionRadius / 25);
    Emitters[4].StartSizeRange.X.Max = 40 * (Other.default.CollisionRadius / 25);
    Emitters[4].StartVelocityRange.Z.Min = 64 * (Other.default.CollisionHeight / 44);
    Emitters[4].StartVelocityRange.Z.Max = 64 * (Other.default.CollisionHeight / 44);

    //spinny thingy trail
    Emitters[5].MaxActiveParticles *= DrawScale;
    Emitters[5].Particles.Length = Emitters[5].MaxActiveParticles;

    //flash teleport flares
    Emitters[6].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
    Emitters[6].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);
    Emitters[7].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
    Emitters[7].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);
    Emitters[8].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
    Emitters[8].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);

    //flash teleport flash
    Emitters[9].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
    Emitters[9].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);

    //the spiral blue trail
    Emitters[10].StartLocationOffset.X = 32 * (Other.default.CollisionRadius / 25);
    Emitters[10].StartLocationOffset.X = 32 * (Other.default.CollisionRadius / 25);
    Emitters[10].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
    Emitters[10].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
    Emitters[10].StartVelocityRange.Z.Min = 64 * (Other.default.CollisionHeight / 44);
    Emitters[10].StartVelocityRange.Z.Max = 64 * (Other.default.CollisionHeight / 44);

    //teleport dust
    Emitters[11].MaxActiveParticles *= DrawScale;
    Emitters[11].Particles.Length = Emitters[11].MaxActiveParticles;
    Emitters[11].StartVelocityRadialRange.Min = -200 * (Other.default.CollisionRadius / 25);
    Emitters[11].StartVelocityRadialRange.Max = -200 * (Other.default.CollisionRadius / 25);

    if(Other.default.CollisionHeight < 44)
    {
        Emitters[2].StartSizeRange.X.Min = 5 * (Other.default.CollisionHeight / 44);
        Emitters[2].StartSizeRange.X.Max = 5 * (Other.default.CollisionHeight / 44);

        Emitters[3].StartSizeRange.X.Min = 5 * (Other.default.CollisionHeight / 44);
        Emitters[3].StartSizeRange.X.Max = 5 * (Other.default.CollisionHeight / 44);
    }
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=1.900000
        FadeInEndTime=0.250000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        Sounds(0)=(Sound=Sound'TURRPG2.Effects.SpawnInStart',Radius=(Min=256.000000,Max=256.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=255.000000,Max=255.000000),Probability=(Min=1.000000,Max=1.000000))
        SpawningSound=PTSC_LinearLocal
        SpawningSoundProbability=(Min=1.000000,Max=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        LifetimeRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(0)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Opacity=0.500000
        FadeOutStartTime=1.900000
        FadeInEndTime=0.250000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EmitterTextures.Flares.EFlareB2'
        LifetimeRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(1)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseRevolution=True
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=1.900000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartLocationOffset=(Y=64.000000)
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=32.000000,Max=32.000000))
        RevolutionsPerSecondRange=(Z=(Min=3.000000,Max=3.000000))
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Roll=16384)
        StartSizeRange=(X=(Min=5.000000,Max=5.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EmitterTextures.Flares.EFlareB'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Y=(Min=-64.000000,Max=-64.000000))
    End Object
    Emitters(2)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ColorScale(0)=(Color=(G=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255))
        FadeOutStartTime=1.000000
        FadeInEndTime=0.100000
        MaxParticles=50
        AddLocationFromOtherEmitter=2
        StartSizeRange=(X=(Min=5.000000,Max=5.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Max=5.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=1.000000))
    End Object
    Emitters(3)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        FadeOutStartTime=1.750000
        FadeInEndTime=0.250000
        MaxParticles=5
        StartLocationOffset=(Z=-64.000000)
        StartSizeRange=(X=(Min=40.000000,Max=40.000000))
        Texture=Texture'XEffectMat.Shock.shock_ring_b'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
    End Object
    Emitters(4)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        Acceleration=(Z=-1.000000)
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        FadeOutStartTime=1.000000
        FadeInEndTime=0.100000
        MaxParticles=50
        AddLocationFromOtherEmitter=2
        StartSizeRange=(X=(Min=2.000000,Max=3.000000))
        Texture=Texture'XEffectMat.Shock.shock_sparkle'
        LifetimeRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(5)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter5'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
        UseDirectionAs=PTDU_Up
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeXByVelocity=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartLocationOffset=(Z=24.000000)
        ScaleSizeByVelocityMultiplier=(X=16.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.BurnFlare1'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=0.100000,Max=0.100000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.500000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(6)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter6'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter7
        UseDirectionAs=PTDU_Up
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeXByVelocity=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartLocationOffset=(Z=-24.000000)
        ScaleSizeByVelocityMultiplier=(X=16.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.BurnFlare1'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=-0.100000,Max=-0.100000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.500000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(7)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter7'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        UseDirectionAs=PTDU_Right
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeXByVelocity=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        ScaleSizeByVelocityMultiplier=(X=16.000000)
        Sounds(0)=(Sound=Sound'TURRPG2.Effects.SpawnInEnd',Radius=(Min=256.000000,Max=256.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=255.000000,Max=255.000000),Probability=(Min=1.000000,Max=1.000000))
        SpawningSound=PTSC_LinearLocal
        SpawningSoundProbability=(Min=1.000000,Max=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.BurnFlare1'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=0.100000,Max=0.100000))
        VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(Z=1.000000))
        VelocityScale(2)=(RelativeTime=1.000000)
    End Object
    Emitters(8)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter8'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Opacity=0.750000
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(9)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter9'

    Begin Object Class=TrailEmitter Name=TrailEmitter0
        TrailShadeType=PTTST_Linear
        MaxPointsPerTrail=60
        DistanceThreshold=4.000000
        UseCrossedSheets=True
        UseColorScale=True
        RespawnDeadParticles=False
        UseRevolution=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        MaxParticles=20
        StartLocationOffset=(X=32.000000,Z=-64.000000)
        RevolutionsPerSecondRange=(Z=(Min=3.000000,Max=3.000000))
        StartSizeRange=(X=(Min=12.000000,Max=12.000000))
        InitialParticlesPerSecond=10.000000
        Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
    End Object
    Emitters(10)=TrailEmitter'TURRPG2.FX_FriendlyMonsterSpawn.TrailEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter37
       UseColorScale=True
       FadeOut=True
       FadeIn=True
       RespawnDeadParticles=False
       SpinParticles=True
       UniformSize=True
       AutomaticInitialSpawning=False
       UseVelocityScale=True
       Acceleration=(Z=200.000000)
       ColorScale(0)=(Color=(G=255))
       ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
       Opacity=0.500000
       FadeOutStartTime=0.100000
       FadeInEndTime=0.100000
       MaxParticles=50
       StartLocationShape=PTLS_Sphere
       SphereRadiusRange=(Min=8.000000,Max=8.000000)
       StartSpinRange=(X=(Max=1.000000))
       StartSizeRange=(X=(Min=5.000000,Max=8.000000))
       InitialParticlesPerSecond=5000.000000
       Texture=Texture'EpicParticles.Flares.FlickerFlare2'
       LifetimeRange=(Min=1.000000,Max=1.000000)
       InitialDelayRange=(Min=2.000000,Max=2.000000)
       StartVelocityRadialRange=(Min=-200.000000,Max=-200.000000)
       GetVelocityDirectionFrom=PTVD_AddRadial
       VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
       VelocityScale(1)=(RelativeTime=0.400000,RelativeVelocity=(X=0.300000,Y=0.300000,Z=0.300000))
       VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
    End Object
    Emitters(11)=SpriteEmitter'TURRPG2.FX_FriendlyMonsterSpawn.SpriteEmitter37'

    AutoDestroy=True
    bNoDelete=False
    RemoteRole=Role_SimulatedProxy
    bNetTemporary=True
    bNotOnDedServer=False
    bAlwaysRelevant=True //to avoid desync
}
