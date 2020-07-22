//=============================================================================
// Artifact_EngineerDestroyTargetSummon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EngineerDestroyTargetSummon extends ArtifactBase_Beam;

const MSG_InvalidTarget = 0x0005;
var localized string Msg_Text_Invalid;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    if(Msg == MSG_InvalidTarget)
        return default.Msg_Text_Invalid;
    return Super.GetMessageString(Msg, Value, Obj);
}

function bool CanAffectTarget(Pawn Other)
{
    local int i;

    if(Other != None && Other.Health > 0)
    {
        for(i = 0; i < InstigatorRPRI.Buildings.Length; i++)
            if(InstigatorRPRI.Buildings[i].Pawn == Other)
                return true;
        for(i = 0; i < InstigatorRPRI.Sentinels.Length; i++)
            if(InstigatorRPRI.Sentinels[i].Pawn == Other)
                return true;
        for(i = 0; i < InstigatorRPRI.Turrets.Length; i++)
            if(InstigatorRPRI.Turrets[i].Pawn == Other)
                return true;
        for(i = 0; i < InstigatorRPRI.Vehicles.Length; i++)
            if(InstigatorRPRI.Vehicles[i].Pawn == Other)
                return true;
        for(i = 0; i < InstigatorRPRI.Utilities.Length; i++)
            if(InstigatorRPRI.Utilities[i].Pawn == Other)
                return true;
    }

    MSG(MSG_InvalidTarget);
    return false;
}

function HitTarget(Pawn Other)
{
    if(Vehicle(Other) != None)
        class'Util'.static.EjectAllDrivers(Vehicle(Other));

    SpawnEffects(Other);
    Other.Destroy();
}

defaultproperties
{
    Msg_Text_Invalid="Invalid target."
    bHarmful=False
    bAllowOnEnemies=False
    bAllowOnMonsters=False
    MaxRange=10000.000000
    Cooldown=1.0000000
    DamagePerAdrenaline=0
    AdrenalineForMiss=0
    MinAdrenaline=0
    CostPerSec=0
    IconMaterial=Texture'DestroyDesiredConstructionIcon'
    ItemName="Destroy Target Construction"
    ArtifactID="DestroyTargetConstruction"
    Description="Destroys target summoned construction."
    bCanBeTossed=False
}
