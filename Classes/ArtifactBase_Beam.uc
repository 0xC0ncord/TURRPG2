//=============================================================================
// ArtifactBase_Beam.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactBase_Beam extends RPGArtifact;

var int AdrenalineForMiss;
var int DamagePerAdrenaline;
var int MaxDamage;
var float MaxRange;
var class<xEmitter> HitEmitterClass;
var class<DamageType> MyDamageType;

var bool bHarmful;
var bool bAllowOnTeammates;
var bool bAllowOnEnemies;
var bool bAllowOnGodMode;
var bool bAllowOnFlagCarriers;
var bool bAllowOnVehicles;
var bool bAllowOnMonsters;

var array<class<Pawn> > ImmunePawnTypes;

function bool CanActivate()
{
    if(!Super.CanActivate())
        return false;

    if(Instigator.Controller.Adrenaline < (AdrenalineForMiss * AdrenalineUsage))
    {
        MSG(MSG_Adrenaline);
        return false;
    }

    return true;
}

function Pawn FindTarget()
{
    local vector StartTrace, HitEndLocation;
    local vector HitLocation, HitNormal;

    StartTrace = Instigator.Location + Instigator.EyePosition();
    HitEndLocation = StartTrace + (vector(Instigator.Controller.GetViewRotation()) * MaxRange);

    return Pawn(Trace(HitLocation, HitNormal, HitEndLocation, StartTrace, true));
}

function bool ValidTarget(Pawn Other)
{
    //Broken
    if(Other == None || Other.Controller == None)
        return false;

    //Self
    if(Other == Instigator)
        return false;

    //Dead
    if(Other.Health <= 0)
        return false;

    return true;
}

function bool CanAffectTarget(Pawn Other)
{
    local bool bSameTeam;

    if(!ValidTarget(Other))
        return false;

    //Spawn Protection
    if(bHarmful && Level.TimeSeconds <= Other.SpawnTime + DeathMatch(Level.Game).SpawnProtectionTime)
        return false;

    bSameTeam = class'Util'.static.SameTeamP(Other, Instigator);

    //Enemies
    if(!bSameTeam && !bAllowOnEnemies)
        return false;

    //Teammates
    if(bSameTeam)
    {
        if(!bAllowOnTeammates)
            return false;
        if(bHarmful && TeamGame(Level.Game) != None && TeamGame(Level.Game).FriendlyFireScale == 0)
            return false;
    }

    //Invulnerability
    if(bHarmful && !bAllowOnGodMode && Other.Controller != None && Other.Controller.bGodMode)
        return false;

    //Vehicles
    if(Vehicle(Other) != None)
    {
        if(!bAllowOnVehicles)
            return false;

        if(Vehicle(Other).bAutoTurret && Vehicle(Other).IsVehicleEmpty())
            return false;
    }

    //Monsters
    if(!bAllowOnMonsters && Monster(Other) != None)
        return false;

    //Immune pawn types
    if(class'Util'.static.InArray(Other.Class, ImmunePawnTypes) >= 0)
        return false;

    //Flag carriers
    if(!bAllowOnFlagCarriers && Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.HasFlag != None)
        return false;

    return true;
}

function HitTarget(Pawn Other)
{
    local int StartHealth, NewHealth;
    local int AdrenalineTaken;
    local int Damage;
    local bool bRunningTriple;
    local int UDamageAdjust;
    local Artifact_TripleDamage TripleArtifact;
    local int HealthTaken;

    StartHealth = Other.Health;

    Damage = Min(MaxDamage, DamagePerAdrenaline * (Instigator.Controller.Adrenaline / AdrenalineUsage));

    bRunningTriple = false;
    if(Instigator.HasUDamage())
    {
        UDamageAdjust = 2;
        TripleArtifact = Artifact_TripleDamage(class'Artifact_TripleDamage'.static.HasArtifact(Instigator));
        if(TripleArtifact != None && TripleArtifact.bActive)
        {
            bRunningTriple = true;
            Damage = Damage / UDamageAdjust;
        }
    }
    else
        UDamageAdjust = 1;

    SpawnEffects(Other);

    Other.TakeDamage(Damage, Instigator, Other.Location, vect(0,0,0), MyDamageType);

    if (Other != None)
        NewHealth = Max(0, Other.Health);
    HealthTaken = StartHealth - NewHealth;

    if (!bRunningTriple)
        AdrenalineTaken = (HealthTaken * AdrenalineUsage) / (DamagePerAdrenaline * UDamageAdjust);
    else
        AdrenalineTaken = (HealthTaken * AdrenalineUsage) / DamagePerAdrenaline;

    InstigatorRPRI.DrainAdrenaline(AdrenalineTaken,Self);
}

function SpawnEffects(Pawn Other)
{
    local xEmitter HitEmitter;
    local Actor A;

    HitEmitter = Spawn(HitEmitterClass,,, Instigator.Location + Instigator.EyePosition() - Instigator.CollisionHeight * vect(0, 0, 0.4), Rotator(Other.Location - (Instigator.Location + Instigator.EyePosition())));
    if (HitEmitter != None)
        HitEmitter.mSpawnVecA = Other.Location;

    A = spawn(class'BlueSparks',,, Instigator.Location);
    if (A != None)
    {
        A.RemoteRole = ROLE_SimulatedProxy;
        A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5 * Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
    }
    A = spawn(class'BlueSparks',,, Other.Location);
    if (A != None)
    {
        A.RemoteRole = ROLE_SimulatedProxy;
        A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5 * Other.TransientSoundVolume,,Other.TransientSoundRadius);
    }
}

function bool DoEffect()
{
    local Pawn Target;

    Target = FindTarget();

    //TODO maybe be a bit nice and don't drain adrenaline if the target is at least valid?
    if(!CanAffectTarget(Target))
    {
        if(AdrenalineForMiss > 0)
            InstigatorRPRI.DrainAdrenaline(AdrenalineForMiss * AdrenalineUsage, Self);
        return false;
    }

    HitTarget(Target);
    DoCooldown();

    return true;
}

defaultproperties
{
    bHarmful=True
    bAllowOnEnemies=True
    bAllowOnMonsters=True
    bAllowOnVehicles=True
    bAllowOnFlagCarriers=True
    HitEmitterClass=Class'FX_Bolt_Cyan'
    MaxRange=3000.000000
    DamagePerAdrenaline=7
    MyDamageType=Class'DamTypeLightningBeam'
    AdrenalineForMiss=4
    MinAdrenaline=4
    CostPerSec=1
    MinActivationTime=0.000000
    MaxDamage=180
    Cooldown=0.500000
    bAllowInVehicle=False
}
