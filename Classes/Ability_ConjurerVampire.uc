//=============================================================================
// Ability_ConjurerVampire.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ConjurerVampire extends Ability_Vampire;

function AdjustTargetDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Injured,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    if(Monster(InstigatedBy) == None)
        return;

    Super.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{
    AbilityName="Conjurer's Vampirism"
    Description="Whenever you (while transformed into a monster) or one of your summoned monsters damages an opponent, you or that summoned monster are healed for $1 of the damage per level (up to your/its starting health amount +$2$3). Damage from artifacts is not affected by this ability. Neither you nor your pets can gain health from self-damage."
    StartingCost=2
    CostAddPerLevel=1
    BonusPerLevel=0.0130
    Category=class'AbilityCategory_Monsters'
}
