//=============================================================================
// Artifact_RemoteDamage.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_RemoteDamage extends ArtifactBase_RemoteEffect;

var int DamageRunTime;
var float ExpPerDamage;

function bool CanAffectTarget(Pawn Other)
{
    return Super.CanAffectTarget(Other) && !Other.HasUDamage();
}

function ModifyEffect(RPGEffect Effect)
{
    Effect.Duration = DamageRunTime;
    Effect_RemoteDamage(Effect).EstimatedUDamageTime = DamageRunTime;
    Effect_RemoteDamage(Effect).ExpPerDamage = ExpPerDamage;
}

defaultproperties
{
    EffectClass=Class'Effect_RemoteDamage'
    ExpPerDamage=0.010000
    DamageRunTime=20
    IconMaterial=Texture'RemoteDamageIcon'
    ItemName="Remote Extra Damage"
    ArtifactID="RemoteDamage"
    Description="Grants target player double damage for 20 seconds."
    HudColor=(R=192,G=0,B=192)
    bCanHaveMultipleCopies=False
}
