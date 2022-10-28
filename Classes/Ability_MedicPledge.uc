//=============================================================================
// Ability_MedicPledge.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MedicPledge extends RPGAbility;

var float EffectRadius;
var float DamageReductionPerLevel;

var int NumTeammates;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    SetTimer(1.0, true);
}

function Timer()
{
    local Controller C;
    local Pawn P;

    NumTeammates = 0;

    if(Instigator == None || Instigator.Health <= 0 || Instigator.Controller == None)
        return;

    if(Instigator.DrivenVehicle != None)
        return;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.Pawn == None || (Bot(C) == None && PlayerController(C) == None))
            continue;

        P = C.Pawn;
        if(
            P != Instigator
            && P.Health > 0
            && P.Controller.SameTeamAs(Instigator.Controller)
            && VSize(P.Location - Instigator.Location) < EffectRadius
            && FastTrace(Instigator.Location, P.Location)
        )
        {
            NumTeammates++;
        }
    }
}

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
    if(Damage > 0 && InstigatedBy == RPRI.Controller.Pawn)
        Damage += float(OriginalDamage) * Min(5, NumTeammates) * BonusPerLevel * float(AbilityLevel);
}

function AdjustPlayerDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Injured,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    if(Damage > 0 && Injured == RPRI.Controller.Pawn)
        Damage = Max(1, Damage - (float(OriginalDamage) * Max(0, 5 - NumTeammates) * DamageReductionPerLevel * float(AbilityLevel)));
}

simulated function string DescriptionText()
{
    return Repl(
        Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel)),
        "$2", class'Util'.static.FormatPercent(DamageReductionPerLevel));
}

defaultproperties
{
    EffectRadius=512.00
    BonusPerLevel=0.05
    DamageReductionPerLevel=0.05
    AbilityName="Medic's Pledge"
    Description="For every level of this ability, you gain the following benefits:|For every teammate near you (up to 5), you gain $1 damage reduction per level. For every teammate not near you (starting from 5, but no lower than 0), you gain $2 damage bonus per level.|This ability will not apply while you are in a vehicle."
    StartingCost=7
    MaxLevel=5
    Category=Class'AbilityCategory_Medic'
}
