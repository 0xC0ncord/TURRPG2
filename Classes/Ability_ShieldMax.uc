//=============================================================================
// Ability_ShieldMax.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_ShieldMax extends RPGAbility;

//server -> client
var float ShieldMax;

//client
var xPawn LastPawn;

replication
{
    reliable if(Role == ROLE_Authority)
        ShieldMax;
}

simulated event Tick(float dt)
{
    Super.Tick(dt);

    if(Role < ROLE_Authority && AbilityLevel > 0 && RPRI != None)
    {
        if(LastPawn != RPRI.Controller.Pawn)
            LastPawn = xPawn(RPRI.Controller.Pawn);

        if(LastPawn != None && LastPawn.ShieldStrengthMax != ShieldMax)
            LastPawn.ShieldStrengthMax = ShieldMax;
    }
}

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);

    if(xPawn(Other) != None)
    {
        ShieldMax = xPawn(Other).default.ShieldStrengthMax + BonusPerLevel * AbilityLevel;
        xPawn(Other).ShieldStrengthMax = ShieldMax;

        if(RPGPawn(Other) != None)
            RPGPawn(Other).MaxShieldAmount = ShieldMax;
    }
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", int(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=1
    AbilityName="Shields Up!"
    StatName="Max Shield Bonus"
    Description="Increases your maximum shield by $1 per level."
    StartingCost=1
    CostAddPerLevel=1
    MaxLevel=100
    Category=class'AbilityCategory_Health'
}
