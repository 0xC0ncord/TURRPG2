//=============================================================================
// Ability_Regen.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_Regen extends RPGAbility;

var config float RegenInterval;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    SetTimer(RegenInterval, true);
}

function Timer()
{
    if(Instigator == None || Instigator.Health <= 0)
    {
        SetTimer(0.0f, false);
        return;
    }

    Instigator.GiveHealth(int(BonusPerLevel) * AbilityLevel, Instigator.HealthMax);
}

//TODO: Dynamic description

defaultproperties
{
    BonusPerLevel=1
    RegenInterval=1.000000

    AbilityName="Regeneration"
    Description="Heals 1 health per second per level.|Does not heal past starting health amount."
    StartingCost=5
    CostAddPerLevel=5
    MaxLevel=6
    Category=class'AbilityCategory_Health'
	IconMaterial=Texture'AbRegenerationIcon'
}
