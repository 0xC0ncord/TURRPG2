//=============================================================================
// Ability_HealingFlames.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_HealingFlames extends RPGAbility;

var config float DurationPerLevel;
var config int HealPerSecond;

function ModifyEffect(
    RPGEffect Heal,
    Pawn Other,
    optional Controller Causer,
    optional float OverrideDuration,
    optional float NewModifier
)
{
    local Effect_HealingFlames Flames;
    local int i, HealMax;
    local Ability_LoadedMedic LM;

    //healing is never applied to the vehicle, so we don't need to give it flames
    if(Vehicle(Other) != None)
        return;

    //if we are doing the healing and its not on ourselves
    if(Effect_Heal(Heal) != None && Causer == RPRI.Controller && Other != RPRI.Controller.Pawn)
    {
        if(RPRI != None)
        {
            LM = Ability_LoadedMedic(RPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
            if(LM != None)
                HealMax = LM.GetHealMax();
        }

        //apply flames here if there isn't one
        Flames = Effect_HealingFlames(class'Effect_HealingFlames'.static.GetFor(Other));

        //do stuff to reset the effect instead of creating a new one
        if(Flames != None)
        {
            //if we didn't create this effect, we need to add ourselves to the medic list
            // (see Effect_HealingFlames)
            if(Flames.EffectCauser != RPRI.Controller)
            {
                i = Flames.MedicQueue.Length;
                Flames.MedicQueue.Length = i + 1;
                Flames.MedicQueue[i].Medic = RPRI.Controller.Pawn;
                Flames.MedicQueue[i].MaxHeal = HealMax;
                Flames.MedicQueue[i].Duration = GetDuration();
            }
            else //if we did create it, just reset its duration
                Flames.Duration = GetDuration();
        }
        else
        {
            Flames = Effect_HealingFlames(class'Effect_HealingFlames'.static.Create(Other, RPRI.Controller, GetDuration(), HealMax));
            if(Flames != None)
            {
                Flames.HealAmount = HealPerSecond;
                Flames.HealMax = HealMax;
                Flames.Start();
            }
        }
    }
}

function float GetDuration()
{
    return DurationPerLevel * AbilityLevel;
}

simulated function string DescriptionText()
{
    local string Text;
    local int i;

    Text = Super.DescriptionText();

    for(i = 0; i < LevelDescription.Length; i++)
    {
        Text = Repl(Text, "$" $ string(i + 1) $ "-2", DurationPerLevel * (i + 1));
        Text = Repl(Text, "$" $ string(i + 1), HealPerSecond * (i + 1));
    }

    return Text;
}

defaultproperties
{
    DurationPerLevel=1.0
    HealPerSecond=5
    AbilityName="Regenerating Flames"
    Description="After healing someone through any means, this ability will extend the healing being done into an effect over time. This ability will not trigger for self-healing."
    LevelDescription(0)="Level 1 will heal teammates $1 every half second for $1-2 seconds."
    LevelDescription(1)="Level 2 will heal teammates $2 every half second for $2-2 seconds."
    LevelDescription(2)="Level 3 will heal teammates $3 every half second for $3-2 seconds."
    LevelDescription(3)="Level 4 will heal teammates $4 every half second for $4-2 seconds."
    LevelDescription(4)="Level 5 will heal teammates $5 every half second for $5-2 seconds."
    StartingCost=3
    CostAddPerLevel=1
    MaxLevel=5
    Category=Class'AbilityCategory_Medic'
}
