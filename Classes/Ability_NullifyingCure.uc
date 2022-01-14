//=============================================================================
// Ability_NullifyingCure.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_NullifyingCure extends RPGAbility;

struct NullifyValueStruct
{
    var float RemovalChance;
    var float WeakenMultiplier;
};
var array<NullifyValueStruct> NullifyValues;

function ModifyEffect(RPGEffect Effect, Pawn Other, optional Controller Causer, optional float OverrideDuration, optional float NewModifier)
{
    local Inventory Inv, NextInv;

    // if we are doing the healing
    if(Effect_Heal(Effect) != None && Effect.EffectCauser == RPRI.Controller)
    {
        Inv = Other.Inventory;
        while(Inv != None)
        {
            NextInv = Inv.Inventory;
            if(RPGEffect(Inv) != None && RPGEffect(Inv).bHarmful)
            {
                if(FRand() < GetRemovalChance())
                {
                    Inv.Destroy();
                    Inv = NextInv;
                    continue;
                }
                else
                    WeakenEffect(RPGEffect(Inv));
            }
            Inv = NextInv;
        }
    }
    else if(Other == RPRI.Controller.Pawn && Effect.bHarmful)
        WeakenEffect(Effect);
}

function WeakenEffect(RPGEffect Effect)
{
    local bool bIsActive;

    bIsActive = Effect.IsInState('Activated');

    if(bIsActive)
        Effect.Stop();

    Effect.Duration = FMax(Effect.Duration - Effect.Duration / GetWeakenMultiplier(), 0);
    if(Effect_Freeze(Effect) != None) //freezing requires special handling
        Effect.Modifier = FMin(Effect.Modifier + (1f - Effect.Modifier) / GetWeakenMultiplier(), 1);
    else
        Effect.Modifier = FMax(Effect.Modifier - Effect.Modifier / GetWeakenMultiplier(), 0);

    if(bIsActive)
        Effect.Start();
}

function float GetRemovalChance()
{
    return NullifyValues[AbilityLevel - 1].RemovalChance;
}

function float GetWeakenMultiplier()
{
    return NullifyValues[AbilityLevel - 1].WeakenMultiplier;
}

simulated function string DescriptionText()
{
    local int i;
    local string Text;

    Text = Super.DescriptionText();

    for(i = 0; i < NullifyValues.Length; i++)
    {
        Text = Repl(Text, "$" $ string(i * 2 + 1), class'Util'.static.FormatPercent(NullifyValues[i].RemovalChance));
        Text = Repl(Text, "$" $ string(i * 2 + 2), class'Util'.static.FormatPercent(NullifyValues[i].WeakenMultiplier));
    }

    return Text;
}

defaultproperties
{
    NullifyValues(0)=(RemovalChance=0.000000,WeakenMultiplier=0.250000)
    NullifyValues(1)=(RemovalChance=0.330000,WeakenMultiplier=0.330000)
    NullifyValues(2)=(RemovalChance=0.660000,WeakenMultiplier=0.500000)
    AbilityName="Nullifying Cure"
    Description="After healing someone through any means, this ability will have a chance to remove negative effects from a teammate. If this ability fails to remove an effect, it will weaken it instead. Passively, any effects applied to you will automatically undergo the same conditions."
    LevelDescription(0)="Level 1 will have a $1 chance to remove negative effects and will weaken them by $2."
    LevelDescription(1)="Level 2 will have a $3 chance to remove negative effects and will weaken them by $4."
    LevelDescription(2)="Level 3 will have a $5 chance to remove negative effects and will weaken them by $6."
    StartingCost=6
    CostAddPerLevel=2
    MaxLevel=3
    Category=class'AbilityCategory_Medic'
}
