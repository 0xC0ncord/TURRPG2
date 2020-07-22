//=============================================================================
// Artifact_SphereHealing.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_SphereHealing extends ArtifactBase_EffectSphere;

var int HealthPerSecond;

function bool CanApplyEffectOn(Pawn Other)
{
    if(EffectClass != None)
        return EffectClass.static.CanBeApplied(Other, Instigator.Controller,, GetMaxHealthBonus());
    return false;
}

function ModifyEffect(RPGEffect Effect)
{
    if(Effect_Heal(Effect) != None)
    {
        Effect_Heal(Effect).HealAmount = HealthPerSecond;
        Effect.Modifier = GetMaxHealthBonus();
    }
}

function int GetMaxHealthBonus()
{
    local Ability_LoadedMedic Ability;

    if(InstigatorRPRI != None)
    {
        Ability = Ability_LoadedMedic(InstigatorRPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
        if(Ability != None)
            return Ability.GetHealMax();
    }

    return 50;
}

defaultproperties
{
    TimerInterval=1.000000
    HealthPerSecond=15
    EffectClass=Class'Effect_Heal'
    EmitterClass=Class'FX_SphereHealing900r'
    MinAdrenaline=28
    CostPerSec=7
    bAllowInVehicle=True
    bCanBeTossed=False
    ArtifactID="SphereHealing"
    IconMaterial=Texture'SphereHealingIcon'
    ItemName="Healing Sphere"
    Description="Creates an aura that heals nearby teammates."
    HudColor=(B=192,G=64)
    bCanHaveMultipleCopies=False
}
