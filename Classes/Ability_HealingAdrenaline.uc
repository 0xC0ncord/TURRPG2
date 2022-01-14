//=============================================================================
// Ability_HealingAdrenaline.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_HealingAdrenaline extends RPGAbility;

function ModifyEffect(
    RPGEffect Heal,
    Pawn Other,
    optional Controller Causer,
    optional float OverrideDuration,
    optional float NewModifier
)
{
    local Inv_HealableDamage Healable;
    local int Adjusted;

    //healing is never applied to the vehicle, so there's no adrenaline to gain from it
    if(Vehicle(Other) != None)
        return;

    //if we are doing the healing and its not on ourselves
    if(Effect_Heal(Heal) != None && Causer == RPRI.Controller && Other != RPRI.Controller.Pawn)
    {
        //try to gain adrenaline from this healing effect

        Healable = Inv_HealableDamage(Other.FindInventoryType(class'Inv_HealableDamage'));
        if(Healable != None && Healable.Damage > 0)
        {
            Adjusted = Min(
                Min(
                    Other.Health + Effect_Heal(Heal).HealAmount,
                    Other.HealthMax + GetMaxHealthBonus()),
                Healable.Damage);

            if(Adjusted>0)
                RPRI.AwardAdrenaline(Effect_Heal(Heal).HealAmount * BonusPerLevel * AbilityLevel, self);
        }
    }
}

function int GetMaxHealthBonus()
{
    local Ability_LoadedMedic LM;
    local RPGPlayerReplicationInfo TRPRI;

    if(Instigator != None)
    {
        TRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Instigator.Controller);
        if(TRPRI != None)
        {
            LM = Ability_LoadedMedic(TRPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
            if(LM != None)
                return LM.GetHealMax();
        }
    }

    return 50;
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=0.05
    AbilityName="Adrenal Rejuvenation"
    Description="After healing someone through any means, this ability will grant you $1 per level of the health given as adrenaline. This ability will not trigger for self-healing."
    StartingCost=5
    CostAddPerLevel=2
    MaxLevel=5
    Category=Class'AbilityCategory_Medic'
}
