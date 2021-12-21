//=============================================================================
// Ability_MetamorphosisRefund.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MetamorphosisRefund extends RPGAbility;

var int CostSpent;
var bool bJustTransformed;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);

    //reset the adrenaline refund on respawn, but not during transformation
    if(!bJustTransformed)
        CostSpent = 0;

    bJustTransformed = false;
}

function ProcessTransformation(Pawn Other, int Cost)
{
    if(Other == None || Other.Controller == None || !Other.Controller.bAdrenalineEnabled)
        return;

    if(CostSpent != 0)
        RPRI.AwardAdrenaline(Max(1, CostSpent * AbilityLevel * BonusPerLevel), Self);
    CostSpent = Cost;

    bJustTransformed = true;
}

simulated function string DescriptionText()
{
    local int i;
    local string Text;

    Text = Super.DescriptionText();

    for(i = 0; i < LevelDescription.Length; i++)
    {
        Text = Repl(Text, "$" $ string(i * 2 + 1), AbilityLevel);
        Text = Repl(Text, "$" $ string(i * 2 + 2), class'Util'.static.FormatPercent(BonusPerLevel * AbilityLevel));
    }

    return Text;
}

defaultproperties
{
    AbilityName="Metamorphic Refund"
    Description="Whenever you transform from a monster into your normal form or another monster, the adrenaline spent on the previous transformation will be partially refunded. Adrenaline granted by this ability will not go past your maximum adrenaline amount."
    LevelDescription(0)="At level $1, up to $2 of the adrenaline spent will be refunded."
    LevelDescription(1)="At level $3, up to $4 of the adrenaline spent will be refunded."
    LevelDescription(2)="At level $5, up to $6 of the adrenaline spent will be refunded."
    BonusPerLevel=0.250000
    StartingCost=3
    CostAddPerLevel=2
    MaxLevel=3
    Category=class'AbilityCategory_Monsters'
}
