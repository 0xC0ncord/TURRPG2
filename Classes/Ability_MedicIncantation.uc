//=============================================================================
// Ability_MedicIncantation.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MedicIncantation extends RPGAbility;

var float RealHealthGain;
var float DamageBonusPerLevel;
var float MaxHealDistance;
var float MaxAttackDistance;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    RealHealthGain = 0;
}

function AdjustTargetDamage(
    out int Damage,
    int OriginalDamage,
    Pawn injured,
    Pawn instigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    local Pawn Target;
    local int HealthGain;
    local float Vampire;
    local Actor_MedicSeeker S;

    if(
        RPRI.Controller.Pawn == None
        || RPRI.Controller.Pawn.Health <= 0
        || DamageType == class'DamTypeMedicIncantation'
        || !class'DevoidEffect_Vampire'.static.CanBeApplied(injured, instigatedBy.Controller)
        || Vehicle(injured) != None
        || instigatedBy != RPRI.Controller.Pawn
    )
    {
        return;
    }

    Vampire = FMax(FMin(injured.Health, float(Damage) * BonusPerLevel * AbilityLevel), 0.0);
    if(Vampire > 0)
    {
        RealHealthGain += Vampire;
        if(RealHealthGain > 1f)
        {
            HealthGain += int(RealHealthGain);
            RealHealthGain -= HealthGain;
            Target = GetHealTarget(injured);
            if(Target != None)
            {
                S = Spawn(class'Actor_MedicSeeker', self,, injured.Location, rotator(Target.Location - injured.Location));
                if(S != None)
                    S.SeekerState = SS_Healing;
            }
            else
            {
                Target = GetAttackTarget(injured, HealthGain);
                if(Target != None)
                {
                    S = Spawn(class'Actor_MedicSeeker', self,, injured.Location, RotRand(false));
                    if(S != None)
                    {
                        S.SeekerState = SS_Attacking;
                        if(injured == Target)
                        {
                            S.bAttackingOrigin = true;
                            S.StartPursueTime = Level.TimeSeconds + 0.5;
                        }
                    }
                }
            }
            if(S != None)
            {
                S.Amount = HealthGain;
                S.Causer = instigatedBy;
                S.Target = Target;
                S.LoadedMedic = Ability_LoadedMedic(RPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
            }
        }
    }
}

final function Pawn GetHealTarget(Pawn P)
{
    local Vehicle V;
    local Controller C;
    local Pawn BestP;

    V = Vehicle(RPRI.Controller.Pawn);
    if(V != None)
    {
        if(
            V.Driver != None
            && V.Driver.Health < V.Driver.HealthMax + GetMaxHealthBonus()
            && VSize(P.Location - V.Location) <= MaxHealDistance
        )
        {
            return V.Driver;
        }
    }
    else if(
        RPRI.Controller.Pawn.Health < RPRI.Controller.Pawn.HealthMax + GetMaxHealthBonus()
        && VSize(P.Location - RPRI.Controller.Pawn.Location) <= MaxHealDistance
    )
    {
        return RPRI.Controller.Pawn;
    }

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(
            C.Pawn != None
            && C.Pawn.Health > 0
            && C.SameTeamAs(RPRI.Controller)
            && (
                VSize(C.Pawn.Location - P.Location) <= MaxHealDistance
                || VSize(C.Pawn.Location - RPRI.Controller.Pawn.Location) <= MaxHealDistance
            )
        )
        {
            V = Vehicle(C.Pawn);
            if(V != None)
            {
                if(
                    V.Driver.Health < V.Driver.HealthMax + GetMaxHealthBonus()
                    && (BestP == None || V.Driver.Health < BestP.Health)
                )
                    BestP = V.Driver;
            }
            else if(
                C.Pawn.Health < C.Pawn.HealthMax + GetMaxHealthBonus()
                && (BestP == None || C.Pawn.Health < BestP.Health)
            )
                BestP = C.Pawn;
        }
    }

    return BestP;
}

final function Pawn GetAttackTarget(Pawn P, int Damage)
{
    local Controller C;
    local array<Controller> ValidTargets;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(
            C.Pawn != None
            && C.Pawn.Health > 0
            && !C.SameTeamAs(RPRI.Controller)
            && C.Pawn.Health > Damage
            && VSize(C.Pawn.Location - P.Location) <= MaxAttackDistance
        )
        {
            ValidTargets[ValidTargets.Length] = C;
        }
    }

    if(ValidTargets.Length > 0)
        return ValidTargets[Rand(ValidTargets.Length)].Pawn;
    return P;
}

final function int GetMaxHealthBonus()
{
    local Ability_LoadedMedic LM;

    LM = Ability_LoadedMedic(RPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
    if(LM != None)
        return LM.GetHealMax();
    return 50;
}

simulated function string DescriptionText()
{
    local string Text;

    Text = Super.DescriptionText();
    Text = Repl(Text, "$1", class'Util'.static.FormatPercent(BonusPerLevel));
    Text = Repl(Text, "$2", class'Util'.static.FormatPercent(DamageBonusPerLevel));

    return Text;
}

defaultproperties
{
    MaxHealDistance=4000.0
    MaxAttackDistance=2000.0
    DamageBonusPerLevel=0.035
    BonusPerLevel=0.05
    AbilityName="Healer's Incantation"
    Description="Whenever you damage an opponent, that opponent's life force is released in the form of life orbs that seek out you or any teammates nearby that require healing, prioritizing you first. When an orb reaches its target, you or that teammate are healed for $1 per level of the damage dealt. If neither you nor any nearby teammates require healing, the orbs will instead seek out other nearby enemies, dealing $2 per level of the damage originally dealt. This ability cannot heal friendly vehicles (but will instead heal their drivers and passengers, if applicable)."
    StartingCost=2
    CostAddPerLevel=2
    MaxLevel=10
    Category=Class'AbilityCategory_Medic'
}
