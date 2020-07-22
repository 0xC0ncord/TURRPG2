//=============================================================================
// Artifact_LightningBolt.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_LightningBolt extends ArtifactBase_Beam;

var float TargetRadius;

function Pawn FindTarget()
{
    local Controller C, BestC;
    local int MostHealth;

    C = Level.ControllerList;
    BestC = None;
    MostHealth = 0;
    while (C != None)
    {
        if ( C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
             && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && C.bGodMode == False && FastTrace(C.Pawn.Location, Instigator.Location))
        {
            if (C.Pawn.Health > MostHealth)
            {
                MostHealth = C.Pawn.Health;
                BestC = C;
            }
        }
        C = C.NextController;
    }

    if(BestC != None)
        return BestC.Pawn;
    return None;
}

function SpawnEffects(Pawn Other)
{
    local xEmitter HitEmitter;
    local Actor A;

    HitEmitter = Spawn(HitEmitterClass,,, Instigator.Location, Rotator(Other.Location - Instigator.Location));
    if (HitEmitter != None)
        HitEmitter.mSpawnVecA = Other.Location;

    A = Spawn(class'BlueSparks',,, Instigator.Location);
    if (A != None)
    {
        A.RemoteRole = ROLE_SimulatedProxy;
        A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5 * Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
    }
    A = Spawn(class'BlueSparks',,, Other.Location);
    if (A != None)
    {
        A.RemoteRole = ROLE_SimulatedProxy;
        A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5 * Other.TransientSoundVolume,,Other.TransientSoundRadius);
    }
}

defaultproperties
{
    HitEmitterClass=Class'FX_Bolt_White'
    MyDamageType=Class'DamTypeLightningBolt'
    TargetRadius=2000.000000
    DamagePerAdrenaline=4
    MaxDamage=100
    AdrenalineForMiss=10
    MinAdrenaline=10
    Cooldown=1.500000
    CostPerSec=1
    MinActivationTime=0.000000
    PickupClass=Class'ArtifactPickup_LightningBolt'
    IconMaterial=Texture'LightningBoltIcon'
    ItemName="Lightning Bolt"
    ArtifactID="Bolt"
    Description="Fires a bolt of lightning at the nearest target with the most health."
    HudColor=(R=200,G=200,B=255)
}
