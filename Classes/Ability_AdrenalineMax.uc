//=============================================================================
// Ability_AdrenalineMax.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_AdrenalineMax extends RPGAbility;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientSetAdrenalineMax;
}

simulated function ClientSetAdrenalineMax(Controller C, int Max)
{
    C.AdrenalineMax = Max;
}

function ModifyPawn(Pawn P)
{
    Super.ModifyPawn(P);

    RPRI.Controller.AdrenalineMax = 100 + AbilityLevel * int(BonusPerLevel);

    if(Level.NetMode == NM_DedicatedServer)
        ClientSetAdrenalineMax(RPRI.Controller, RPRI.Controller.AdrenalineMax);
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", int(BonusPerLevel));
}

defaultproperties
{
    AbilityName="Adrenaline Container"
    StatName="Max Adrenaline Bonus"
    Description="Increases your maximum adrenaline amount by $1 per level.|Combos can still be activated with 100 adrenaline."
    MaxLevel=400
    StartingCost=1
    BonusPerLevel=1
    Category=class'AbilityCategory_Adrenaline'
}
