//=============================================================================
// Ability_HealingDefender.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_HealingDefender extends RPGAbility;

var config float PercentPerLevel, DurationPerLevel;

function ModifyEffect(
    RPGEffect Heal,
    Pawn Other,
    optional Controller Causer,
    optional float OverrideDuration,
    optional float NewModifier
)
{
    local Effect_HealingDefender Defender;
    local int i;

    //healing is never applied to vehicles, so we're not going to give it damage reduction either.
    if(Vehicle(Other) != None)
        return;

    //if we are doing the healing
    if(Effect_Heal(Heal) != None && Causer == RPRI.Controller)
    {
        //apply defender here if there isn't one
        Defender = Effect_HealingDefender(class'Effect_HealingDefender'.static.GetFor(Other));

        //do stuff to reset the effect instead of creating a new one
        if(Defender != None)
        {
            //if we didn't create this effect, we need to add ourselves to the medic list
            //(see Effect_HealingDefender)
            if(Defender.EffectCauser != RPRI.Controller)
            {
                i = Defender.MedicQueue.Length;
                Defender.MedicQueue.Length = i + 1;
                Defender.MedicQueue[i].Medic = RPRI.Controller.Pawn;
                Defender.MedicQueue[i].Modifier = GetModifier();
                Defender.MedicQueue[i].Duration = GetDuration();
            }
            else //if we did create it, just reset its timer
                Defender.Duration = GetDuration();
        }
        else
        {
            Defender = Effect_HealingDefender(class'Effect_HealingDefender'.static.Create(Other, RPRI.Controller, GetDuration(), GetModifier()));
            if(Defender != None)
                Defender.Start();
        }
    }
}

function float GetDuration()
{
    return DurationPerLevel * AbilityLevel;
}

function float GetModifier()
{
    return AbilityLevel;
}

simulated function string DescriptionText()
{
    local string Text;
    local int i;

    Text = Super.DescriptionText();

    for(i = 0; i < LevelDescription.Length; i++)
    {
        Text = Repl(Text, "$" $ string(i + 1) $ "-2", DurationPerLevel * (i + 1));
        Text = Repl(Text, "$" $ string(i + 1), class'Util'.static.FormatPercent(PercentPerLevel * (i + 1)));
    }

    return Text;
}

defaultproperties
{
    PercentPerLevel=0.03
    DurationPerLevel=0.5
    AbilityName="Regenerating Defender"
    Description="After healing a teammate through any means, this ability will grant the teammate being healed additional damage reduction. This effect may also be triggered for self-healing."
    LevelDescription(0)="Level 1 will grant teammates +$1 damage reduction for $1-2 seconds."
    LevelDescription(1)="Level 2 will grant teammates +$2 damage reduction for $2-2 seconds."
    LevelDescription(2)="Level 3 will grant teammates +$3 damage reduction for $3-2 seconds."
    LevelDescription(3)="Level 4 will grant teammates +$4 damage reduction for $4-2 seconds."
    LevelDescription(4)="Level 5 will grant teammates +$5 damage reduction for $5-2 seconds."
    StartingCost=4
    CostAddPerLevel=3
    MaxLevel=5
    Category=Class'AbilityCategory_Medic'
}
