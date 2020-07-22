//=============================================================================
// ArtifactBase_Blast.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactBase_Blast extends RPGArtifact
    config(TURRPG2)
    abstract
    HideDropDown;

var class<Blast> BlastClass;
var class<RPGBlastProjectile> BlastProjectileClass;
var bool bUseProjectile;

var int AIHealthMin, AIMinTargets;
var bool bFriendly;

var Projectile BlastProjectile;

function BotWhatNext(Bot Bot)
{
    if(
        !HasActiveArtifact(Instigator) &&
        Bot.Adrenaline >= CostPerSec &&
        Instigator.Health >= AIHealthMin && //should survive until then
        CountNearbyEnemies(BlastClass.default.Radius, bFriendly) >= AIMinTargets
    )
    {
        Activate();
    }
}

function Actor SpawnBlast()
{
    local rotator R;

    if(PlayerController(Instigator.Controller).bBehindView)
        R = PlayerController(Instigator.Controller).CalcViewRotation;
    else
        R = Instigator.Controller.GetViewRotation();

    if(bUseProjectile)
        return Instigator.Spawn(BlastProjectileClass, Instigator.Controller,, Instigator.Location, R);
    return Instigator.Spawn(BlastClass, Instigator.Controller,,Instigator.Location);
}

function bool DoEffect()
{
    return (SpawnBlast() != None);
}

defaultproperties
{
    bUseProjectile=True

    bChargeUp=True

    AIHealthMin=50
    AIMinTargets=2
    bFriendly=False

    ActivateSound=Sound'ONSVehicleSounds-S.LaserSounds.Laser09'

    bAllowInVehicle=False
    bCanBeTossed=False

    MaxUses=1
}
