//=============================================================================
// FX_HuntersMarkOverlay.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_HuntersMarkOverlay extends Effects;

var Material Material;

var bool bInitialized;
var Pawn OwnerPawn;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        OwnerPawn;
}

simulated function Init()
{
    local int i;

    if(bInitialized)
        return;
    bInitialized = true;

    if(Owner != OwnerPawn)
        SetOwner(OwnerPawn);

    LinkMesh(Owner.Mesh);
    Skins.Length = 10;
    for(i = 0; i < 10; i++)
        Skins[i] = Material;
    Texture = Material;
    SetDrawScale(Owner.DrawScale + 0.01);
    SetDrawScale3D(Owner.DrawScale3D);
}

simulated function PostBeginPlay()
{
    if(Level.NetMode == NM_DedicatedServer)
        Disable('Tick');
    if(Level.NetMode != NM_Client)
    {
        OwnerPawn = Pawn(Owner);
        SetOwner(OwnerPawn);
        Init();
    }
}

simulated function PostNetBeginPlay()
{
    if(Level.NetMode != NM_Client)
        return;
    if(OwnerPawn != None)
        Init();
    else
        Destroy();
}

simulated function Tick(float DeltaTime)
{
    local name OwnerAnimName;
    local float OwnerAnimFrame, OwnerAnimRate;
    local name MyAnimName;
    local float MyAnimFrame, MyAnimRate;

    if(Owner != None)
    {
        if(Pawn(Owner).Health <= 0)
        {
            Disable('Tick');
            Destroy();
            return;
        }

        PrePivot = Owner.PrePivot;
        if(bHidden != Owner.bHidden)
            bHidden = Owner.bHidden;
        if(DrawScale - 0.01 != Owner.DrawScale)
            SetDrawScale(Owner.DrawScale + 0.01);

        //bAnimByOwner is broken with VertMeshes...
        //This is a total hack to fake it
        if(VertMesh(Mesh) != None)
        {
            GetAnimParams(0, MyAnimName, MyAnimFrame, MyAnimRate);
            Owner.GetAnimParams(0, OwnerAnimName, OwnerAnimFrame, OwnerAnimRate);

            if(MyAnimName != OwnerAnimName || MyAnimFrame != OwnerAnimFrame || MyAnimRate != OwnerAnimRate)
            {
                PlayAnim(OwnerAnimName, OwnerAnimRate);
                SetAnimFrame(OwnerAnimFrame);
            }
        }
    }
    else
    {
        if(!bHidden)
            bHidden = true;
        if(OwnerPawn != None)
            SetOwner(OwnerPawn);
    }
}

defaultproperties
{
    Material=FinalBlend'HuntersMarkFinal'
    bTrailerSameRotation=True
    bTrailerPrePivot=True
    bNetTemporary=False
    bSkipActorPropertyReplication=True
    bNetInitialRotation=False
    Physics=PHYS_Trailer
    RemoteRole=ROLE_SimulatedProxy
    DrawType=DT_Mesh
    AmbientGlow=250
    ScaleGlow=2.000000
    bAnimByOwner=True
    bOwnerNoSee=True
    bNoRepMesh=True
}
