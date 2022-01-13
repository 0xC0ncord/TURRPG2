//=============================================================================
// WeaponModifier_ChainLightning.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_ChainLightning extends RPGWeaponModifier;

const MAX_STRIKES = 8;

var float ChainLightningRadius;
var Class<xEmitter> HitEmitterClass;

var localized string ChainLightningText;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
    if(!Super.AllowedFor(Weapon, Other))
        return false;
    return Weapon == class'SniperRifle';
}

function AdjustTargetDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Victim,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType)
{
    local int TempModifier;
    local float TempDamageBonus;
    local Controller C;
    local Controller NextC;
    local xEmitter HitEmitter;
    local int Strikes;
    local Pawn LastDamaged;
    local Controller BeenHit[MAX_STRIKES];
    local bool bNotBeenHit;
    local int i;

    TempModifier = Modifier + 1;
    TempDamageBonus = DamageBonus;
    if(Modifier > MaxModifier)
        TempModifier = MaxModifier + Min(1, (Modifier - MaxModifier) / 2);
    if(Damage > 0 && Victim != None && DamageType != class'DamTypeChainLightningBolt')
    {
        LastDamaged = Victim;
        BeenHit[0] = Victim.Controller;

        Strikes = 0;
        for(C = Level.ControllerList; C != None; C = NextC)
        {
            // grab next controller now in case target dies
            NextC = C.NextController;

            if(
                C.Pawn != None
                && C.Pawn != Instigator
                && C.Pawn.Health > 0
                && !class'Util'.static.SameTeamP(C.Pawn, InstigatedBy)
                && VSize(C.Pawn.Location - Victim.Location) < ChainLightningRadius
                && FastTrace(C.Pawn.Location, LastDamaged.Location)
            )
            {
                bNotBeenHit = True;
                for(i = 0; i < MAX_STRIKES; i++)
                    if(C == BeenHit[i])
                        bNotBeenHit = false;

                if(bNotBeenHit)
                {
                    HitEmitter = Spawn(HitEmitterClass,,, LastDamaged.Location, rotator(C.Pawn.Location - Victim.Location));
                    if(HitEmitter != None)
                        HitEmitter.mSpawnVecA = C.Pawn.Location;
                    C.Pawn.TakeDamage(Damage, Instigator, C.Pawn.Location, vect(0, 0, 0),class'DamTypeChainLightningBolt');
                    Strikes++;
                    BeenHit[Strikes] = C;
                    LastDamaged = C.Pawn;
                }
            }

            if(Strikes >= TempModifier)
                break;
        }

        if(Strikes > 0)
            Identify();
    }
    Super.AdjustTargetDamage(Damage, OriginalDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(ChainLightningText);
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);
    StaticAddToDescription(Description, Modifier, default.ChainLightningText);

    return Description;
}

defaultproperties
{
    ChainLightningText="on-hit chain lightning"
    ChainLightningRadius=1024.00
    HitEmitterClass=Class'XEffects.LightningBolt'
    DamageBonus=0.01
    ModifierOverlay=Shader'ChainLightningShader'
    MaxModifier=4
    AIRatingBonus=0.08
    PatternPos="$W of Chain Lightning"
    bCanHaveZeroModifier=True
}
