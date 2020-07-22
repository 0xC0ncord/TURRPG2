//=============================================================================
// Artifact_RemoteMax.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_RemoteMax extends ArtifactBase_RemoteEffect;

function BotWhatNext(Bot Bot); //too complicated for them

function bool CanAffectTarget(Pawn Other)
{
    local RPGWeaponModifier RW;

    if(!Super.CanAffectTarget(Other))
        return false;

    RW = class'RPGWeaponModifier'.static.GetFor(Other.Weapon);
    return RW != None && RW.Modifier < RW.MaxModifier;
}

function RPGEffect ApplyEffect(Pawn Other)
{
    local RPGWeaponModifier RW;

    RW = class'RPGWeaponModifier'.static.GetFor(Other.Weapon);
    RW.SetModifier(RW.MaxModifier);

    return None;
}

defaultproperties
{
    MaxRange=3000.000000
    MinAdrenaline=150
    CostPerSec=150
    XPforUse=15
    bCanBeTossed=False
    IconMaterial=Texture'RemoteMaxIcon'
    ItemName="Remote Max Modifier"
    ArtifactID="RemoteMax"
    Description="Instantly maxes the magic level of the target teammates's magic weapon."
    HudColor=(R=192,G=0,B=255)
    bCanHaveMultipleCopies=False
}
