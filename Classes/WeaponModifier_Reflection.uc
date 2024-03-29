//=============================================================================
// WeaponModifier_Reflection.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Reflection extends RPGWeaponModifier;

struct ReflectMapStruct
{
    var class<DamageType> DamageType;
    var class<WeaponFire> WeaponFire;
};
var config array<ReflectMapStruct> ReflectMap;
var config float BaseChance;

var config array<class<RPGEffect> > ReflectEffects;

var bool bLock;

var localized string ReflectionText;

function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier)
{
    local RPGEffect Reflected;

    if(class'Util'.static.InArray(EffectClass, ReflectEffects) >= 0) {
        if(Causer.Pawn != None && WeaponModifier_Reflection(class'RPGWeaponModifier'.static.GetFor(Causer.Pawn.Weapon)) == None) {
            Reflected = EffectClass.static.Create(Causer.Pawn, Instigator.Controller, Duration, Modifier);
            if(Reflected != None)
                Reflected.Start();
        }
        return false;
    }

    return true;
}

function class<WeaponFire> MapDamageType(class<DamageType> DamageType)
{
    local int i;

    for(i = 0; i < ReflectMap.Length; i++)
    {
        if(ReflectMap[i].DamageType == DamageType)
            return ReflectMap[i].WeaponFire;
    }
    return None;
}

function WeaponFire FindWeaponFire(Pawn Other, class<WeaponFire> WFClass)
{
    local Inventory Inv;
    local Weapon W;
    local int i;

    for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        W = Weapon(Inv);
        if(W != None)
        {
            for(i = 0; i < W.NUM_FIRE_MODES; i++)
            {
                if(ClassIsChildOf(W.FireModeClass[i], WFClass))
                    return W.GetFireMode(i);
            }
        }
    }

    return None;
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local WeaponFire WF;
    local class<WeaponFire> WFClass;
    local rotator ReflectDir;

    if(Damage > 0 && Instigator != InstigatedBy && !Instigator.Controller.SameTeamAs(InstigatedBy.Controller))
    {
        WFClass = MapDamageType(DamageType);
        if(WFClass != None && FRand() < (BaseChance + float(Modifier) * BonusPerLevel))
        {
            if(bLock) {
                Warn("Reflection: Recursion!!");
            } else {
                bLock = true;

                Identify();
                ReflectDir = rotator(HitLocation - Weapon.Location);

                WF = FindWeaponFire(InstigatedBy, WFClass);
                if(WF != None)
                {
                    if(ProjectileFire(WF) != None) {
                        //Log("Reflection: SpawnProjectile" @ WF);
                        ProjectileFire(WF).SpawnProjectile(Instigator.Location + Instigator.CollisionHeight * vector(ReflectDir), ReflectDir);
                    } else if(InstantFire(WF) != None) {
                        //Log("Reflection: DoTrace using " @ WF);
                        InstantFire(WF).SpawnBeamEffect(Instigator.Location + Instigator.CollisionHeight * vector(ReflectDir), ReflectDir, HitLocation, vector(ReflectDir), 0);
                    }
                }
                /*
                else
                {
                    Log("Couldn't find" @ WFClass @ "for" @ InstigatedBy, 'DEBUG');
                }
                */

                bLock = false;
            }

            Damage = 0;
            Momentum = vect(0, 0, 0);
        }
    }
}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(Repl(ReflectionText, "$1", class'Util'.static.FormatPercent(BaseChance + float(Modifier) * BonusPerLevel)));
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    Description = Super.StaticGetDescription(Modifier);

    StaticAddToDescription(Description, Modifier, Repl(default.ReflectionText, "$1", class'Util'.static.FormatPercent(default.BaseChance + float(Modifier) * default.BonusPerLevel)));

    return Description;
}

defaultproperties
{
    ReflectionText="$1 reflection chance"
    DamageBonus=0.05
    BaseChance=0.25
    BonusPerLevel=0.10
    MinModifier=1
    MaxModifier=7
    //ModifierOverlay=Shader'AWGlobal.Shaders.WetBlood01aw'
    ModifierOverlay=TexEnvMap'VMVehicles-TX.Environments.ReflectionEnv'
    PatternPos="Reflecting $W"
    bCanHaveZeroModifier=True
    //Reflect
    ReflectMap(0)=(DamageType=class'DamTypeLinkPlasma',WeaponFire=class'LinkAltFire')
    ReflectMap(1)=(DamageType=class'DamTypeShockBeam',WeaponFire=class'ShockBeamFire')
    ReflectMap(2)=(DamageType=class'DamTypeShockBall',WeaponFire=class'ShockProjFire')
    ReflectEffects(0)=class'Effect_NullEntropy'
    //AI
    AIRatingBonus=0.025
    CountersModifier(0)=class'WeaponModifier_NullEntropy'
    CountersDamage(0)=class'DamTypeShockBeam'
    CountersDamage(1)=class'DamTypeShockBall'
    CountersDamage(2)=class'DamTypeLinkPlasma'
}
