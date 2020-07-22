//=============================================================================
// FX_FriendlyMonster.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_FriendlyMonster extends Emitter;

var PlayerReplicationInfo MasterPRI;

replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        MasterPRI;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    //force default rotation
    SetRotation(default.Rotation);
}

simulated function PostNetReceive()
{
    if (Base != None)
    {
        Initialize();
    }
}

simulated function Initialize()
{
    local float Modifier, Height, StartSize;
    local Pawn P;
    local PlayerController PC;

    Modifier = Base.CollisionRadius / CollisionRadius;
    Height = -Base.CollisionHeight * 1.25;
    Emitters[0].StartLocationOffset.Y = Height;
    StartSize = default.Emitters[0].StartSizeRange.Z.Min * Modifier;
    Emitters[0].StartSizeRange.Z.Min = StartSize;
    Emitters[0].StartSizeRange.Z.Max = StartSize;
    Emitters[0].StartSizeRange.X.Min = StartSize;
    Emitters[0].StartSizeRange.X.Max = StartSize;
    StartSize = FMax(default.Emitters[0].StartSizeRange.Y.Min, StartSize * 0.5);
    Emitters[0].StartSizeRange.Y.Min = StartSize;
    Emitters[0].StartSizeRange.Y.Max = StartSize;
    Emitters[0].Disabled = false;
    Emitters[1].StartLocationOffset.Y = Height;
    Emitters[1].StartLocationPolarRange.Z.Max = default.Emitters[1].StartLocationPolarRange.Z.Max * Modifier;
    Emitters[1].StartLocationPolarRange.Z.Min = default.Emitters[1].StartLocationPolarRange.Z.Min * Modifier;
    Emitters[1].Disabled = false;

    PC = Level.GetLocalPlayerController();
    if (PC != None && PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo == MasterPRI)
    {
        Emitters[0].ColorScale[0].Color.R = 0;
        Emitters[0].ColorScale[0].Color.G = 255;
        Emitters[0].ColorScale[1].Color.R = 0;
        Emitters[0].ColorScale[1].Color.G = 255;
        Emitters[1].ColorScale[0].Color.R = 64;
        Emitters[1].ColorScale[0].Color.G = 255;
    }
    else
    {
        P = Pawn(Base);
        if (P.GetTeamNum() == 1)
        {
            Emitters[0].ColorScale[0].Color.R = 0;
            Emitters[0].ColorScale[0].Color.B = 255;
            Emitters[0].ColorScale[1].Color.R = 0;
            Emitters[0].ColorScale[1].Color.B = 255;
            Emitters[1].ColorScale[0].Color.R = 64;
            Emitters[1].ColorScale[0].Color.B = 255;
        }
    }
}

//In Assault, the begin round reset happens after we've been spawned
//since we don't need Assault screwing with us anyway, just disable the function
function Reset();

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'TURRPG2.Effects.Halo'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         Disabled=True
         Backup_Disabled=True
         ColorScale(0)=(Color=(R=255,A=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,A=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseRotationFrom=PTRS_Offset
         StartSizeRange=(Y=(Min=1.500000,Max=1.500000))
         LifetimeRange=(Min=0.001000,Max=0.001000)
     End Object
     Emitters(0)=MeshEmitter'FX_FriendlyMonster.MeshEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         Disabled=True
         Backup_Disabled=True
         UniformMeshScale=False
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=64,G=64,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=1.005000
         CoordinateSystem=PTCS_Relative
         MaxParticles=25
         StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000))
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=12.000000,Max=12.000000))
         RevolutionsPerSecondRange=(Z=(Min=0.200000,Max=0.200000))
         UseRotationFrom=PTRS_Offset
         StartSizeRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=200.000000
         Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.500000,Max=1.750000)
         StartVelocityRange=(Y=(Min=25.000000,Max=25.000000))
     End Object
     Emitters(1)=SpriteEmitter'FX_FriendlyMonster.SpriteEmitter1'

     bNoDelete=False
     RemoteRole=ROLE_SimulatedProxy
     Rotation=(Roll=16384)
     bHardAttach=True
     CollisionRadius=25.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bNetNotify=True
}
