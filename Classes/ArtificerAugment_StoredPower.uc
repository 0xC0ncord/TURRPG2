//=============================================================================
// ArtificerAugment_StoredPower.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_StoredPower extends ArtificerAugmentBase;

var float MovementNeeded;

function RPGTick(float dt)
{
    local Actor_StoredPowerExplosion A;
    local float Multiplier;
    local float SpeedMultiplier;

    if(Instigator.Velocity != vect(0, 0, 0))
        MovementNeeded -= dt * 1.33 * VSize(Instigator.Velocity) * (1 + (BonusPerLevel * Modifier));
    else
        MovementNeeded -= dt * 0.33 * Instigator.default.GroundSpeed * (1 + (BonusPerLevel * Modifier));

    if(MovementNeeded > 0)
        return;

    Multiplier = 1.0 + (BonusPerLevel * Modifier);
    if(Instigator.Velocity != vect(0, 0, 0))
        SpeedMultiplier =  FMax(0, 1f - (VSize(Instigator.Velocity) / Instigator.default.GroundSpeed));

    MovementNeeded += 1.25 * Instigator.default.GroundSpeed;

    A = Instigator.Spawn(class'Actor_StoredPowerExplosion', Instigator,, Instigator.Location);
    A.Multiplier = Multiplier + SpeedMultiplier;
    A.InitEffects();
}

function StartEffect()
{
    MovementNeeded = 1.25 * Instigator.default.GroundSpeed;
}

defaultproperties
{
    MaxLevel=3
    BonusPerLevel=0.1
    ModifierName="Stored Power"
    Description="leaves delayed explosions"
    LongDescription="Causes you to leave delayed explosions while moving. The frequency and damage of these explosions are dependent on your movement speed but are increased by each level of this augment."
    IconMaterial=Texture'TURRPG2.WOPIcons.HealthRegenIcon'
    ModifierOverlay=Combiner'WOPWeapons.StoredPowerShader'
    ModifierColor=(R=174,G=100,B=255)
}
