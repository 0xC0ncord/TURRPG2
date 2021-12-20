//=============================================================================
// Effect_Blindness.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Blindness extends RPGEffect;

struct ZoneInfoModStruct
{
    var ZoneInfo ZoneInfo;
    var bool bDistanceFog;
    var Color DistanceFogColor;
    var float DistanceFogStart;
    var float DistanceFogEnd;
};
var array<ZoneInfoModStruct> ZoneInfoMods;

struct PhysicsVolumeModStruct
{
    var PhysicsVolume PhysicsVolume;
    var bool bDistanceFog;
    var Color DistanceFogColor;
    var float DistanceFogStart;
    var float DistanceFogEnd;
};
var array<PhysicsVolumeModStruct> PhysicsVolumeMods;

var PlayerController OwnerController;

var Emitter SkyHack;

simulated function ClientStart()
{
    OwnerController = Level.GetLocalPlayerController();
    if(Level.NetMode == NM_Client)
    {
        bClientActivated = True;
        GotoState('Activated');
    }
}

simulated state Activated
{
    simulated function BeginState()
    {
        local ZoneInfo Z;
        local PhysicsVolume P;
        local int i;

        if(Role == Role_Authority)
            Super.BeginState();

        if(Level.NetMode == NM_DedicatedServer)
            return;

        if(OwnerController == Instigator.Controller)
        {
            SkyHack = Spawn(class'FX_BlindnessSkyHack', self,, OwnerController.CalcViewLocation, OwnerController.CalcViewRotation);
            OwnerController.ClientFlash(0, vect(0, 0, 0));

            foreach AllActors(class'ZoneInfo', Z)
            {
                if(Z != None)
                {
                    i = ZoneInfoMods.Length;
                    ZoneInfoMods.Length = i + 1;
                    ZoneInfoMods[i].ZoneInfo = Z;
                    ZoneInfoMods[i].bDistanceFog = Z.bDistanceFog;
                    ZoneInfoMods[i].DistanceFogColor = Z.DistanceFogColor;
                    ZoneInfoMods[i].DistanceFogStart = Z.DistanceFogStart;
                    ZoneInfoMods[i].DistanceFogEnd = Z.DistanceFogEnd;

                    Z.bDistanceFog = True;
                    Z.DistanceFogStart = 0;
                    Z.DistanceFogEnd = 256;
                    Z.DistanceFogColor.A = 255;
                    Z.DistanceFogColor.R = 0;
                    Z.DistanceFogColor.G = 0;
                    Z.DistanceFogColor.B = 0;
                }
            }
            foreach AllActors(class'PhysicsVolume', P)
            {
                if(P != None)
                {
                    i = PhysicsVolumeMods.Length;
                    PhysicsVolumeMods.Length = i + 1;
                    PhysicsVolumeMods[i].PhysicsVolume = P;
                    PhysicsVolumeMods[i].bDistanceFog = P.bDistanceFog;
                    PhysicsVolumeMods[i].DistanceFogColor = P.DistanceFogColor;
                    PhysicsVolumeMods[i].DistanceFogStart = P.DistanceFogStart;
                    PhysicsVolumeMods[i].DistanceFogEnd = P.DistanceFogEnd;

                    P.bDistanceFog = True;
                    P.DistanceFogStart = 0;
                    P.DistanceFogEnd = 256;
                    P.DistanceFogColor.A = 255;
                    P.DistanceFogColor.R = 0;
                    P.DistanceFogColor.G = 0;
                    P.DistanceFogColor.B = 0;
                }
            }
    }
    }

    simulated function Tick(float dt)
    {
        if(Role == Role_Authority)
            Super.Tick(dt);

        if(Level.NetMode == NM_DedicatedServer || OwnerController != Instigator.Controller)
            return;

        if(SkyHack != None)
        {
            SkyHack.SetLocation(OwnerController.CalcViewLocation);
            SkyHack.SetRotation(OwnerController.CalcViewRotation);
        }
    }

    simulated function EndState()
    {
        if(OwnerController == Instigator.Controller)
        {
            OwnerController.ClientFlash(0, vect(0, 0, 0));
            CleanUp();
        }
        if(Role == Role_Authority)
            Super.EndState();
    }
}

simulated function Destroyed()
{
    CleanUp();
    Super.Destroyed();
}

simulated function CleanUp()
{
    local int i;

    for(i = 0; i < ZoneInfoMods.Length; i++)
    {
        if(ZoneInfoMods[i].ZoneInfo != None)
        {
            ZoneInfoMods[i].ZoneInfo.bDistanceFog = ZoneInfoMods[i].bDistanceFog;
            ZoneInfoMods[i].ZoneInfo.DistanceFogStart = ZoneInfoMods[i].DistanceFogStart;
            ZoneInfoMods[i].ZoneInfo.DistanceFogEnd = ZoneInfoMods[i].DistanceFogEnd;
            ZoneInfoMods[i].ZoneInfo.DistanceFogColor = ZoneInfoMods[i].DistanceFogColor;
        }
    }

    for(i = 0; i < PhysicsVolumeMods.Length; i++)
    {
        if(PhysicsVolumeMods[i].PhysicsVolume != None)
        {
            PhysicsVolumeMods[i].PhysicsVolume.bDistanceFog = PhysicsVolumeMods[i].bDistanceFog;
            PhysicsVolumeMods[i].PhysicsVolume.DistanceFogStart = PhysicsVolumeMods[i].DistanceFogStart;
            PhysicsVolumeMods[i].PhysicsVolume.DistanceFogEnd = PhysicsVolumeMods[i].DistanceFogEnd;
            PhysicsVolumeMods[i].PhysicsVolume.DistanceFogColor = PhysicsVolumeMods[i].DistanceFogColor;
        }
    }

    if(SkyHack != None)
        SkyHack.Destroy();
}

defaultproperties
{
    EffectClass=class'FX_Blindness'
    EffectMessageClass=class'EffectMessage_Blindness'
    StatusIconClass=class'StatusIcon_Blindness'
}
