//=============================================================================
// Ability_CounterShove.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_CounterShove extends RPGAbility;

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local float MomentumMod;

    if(VSize(Momentum) <= 0)
        return;

    if(DamageType == class'DamTypeCounterShove' || DamageType == class'DamTypeRetaliation')
        return;

    if(InstigatedBy == Injured || InstigatedBy == None || Injured.Controller.SameTeamAs(InstigatedBy.Controller))
        return;

    if(Vehicle(Injured) != None)
    {
        MomentumMod = -(0.0075 * float(AbilityLevel));
    }
    else
    {
        if(AbilityLevel < 5)
            MomentumMod = -(0.75 * float(AbilityLevel));
        else
            MomentumMod = -4.00;
    }

    //TODO: RPGEffect
    InstigatedBy.TakeDamage(0, Injured, InstigatedBy.Location, (Momentum * Injured.Mass) * MomentumMod, class'DamTypeCounterShove');
}

defaultproperties
{
    AbilityName="Counter Shove"
    Description="Whenever you are damaged by an opponent, 75% of the momentum per level is also done to the opponent who hurt you (or 400% at level 5)|This ability will not counter Counter Shove or Retaliation."
    StartingCost=5
    CostAddPerLevel=5
    MaxLevel=5
    ForbiddenAbilities(0)=(AbilityClass=class'Ability_IronLegs',Level=1)
    ForbiddenAbilities(1)=(AbilityClass=class'Ability_Retaliation',Level=1)
    Category=class'AbilityCategory_Damage'
}
