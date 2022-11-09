//=============================================================================
// WeaponModifier_EngineerLink.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_EngineerLink extends RPGWeaponModifier;

var array<float> DamageBonusFromLinks;
var float ShieldBoostingXPPercent;
var float SpiderGrowthRate;

var Ability_ShieldBoosting Ability;
var float SpiderBoostLevel;
var bool bHasTransRepair;

var localized string ProjectileDamageText, ShaftDamageText, ProjectileSpeedText, FireRateText, ShaftRangeText;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
    if(ClassIsChildOf(Weapon, class'LinkGun'))
        return true;

    return false;
}

//this modifier should never be removed
static function bool AllowRemoval(Weapon W, int Modifier)
{
    return false;
}

function BoostShield(Pawn P, int Amount)
{
    local Effect_ShieldBoost Boost;

    Boost = Effect_ShieldBoost(class'Effect_ShieldBoost'.static.Create(P, Instigator.Controller));
    if(Boost != None)
    {
        Boost.ShieldAmount = Amount;
        Boost.BoostingLevel = Ability.AbilityLevel;
        Boost.ShieldBoostingPercent = Ability.ShieldBoostingPercent;
        Boost.Start();
    }
}

function BoostMine(ONSMineProjectile Mine, float Rate)
{
    local vector NewLoc;

    // this code based on the mutator by Rachel 'Angel Mapper' Cordone
    NewLoc = Mine.Location;
    NewLoc.Z += 2 * Rate;
    Mine.SetDrawScale(Mine.DrawScale * Rate);
    Mine.SetCollisionSize(Mine.CollisionRadius * Rate, Mine.CollisionHeight * Rate);
    Mine.SetLocation(NewLoc);
    Mine.DamageRadius *= Rate;
    Mine.Damage *= Rate;
    Mine.MomentumTransfer *= Rate;
    Mine.SetPhysics(PHYS_Falling);
}

function Ability_ShieldBoosting GetShieldBoostingAbility()
{
    if(RPRI == None)
        return None;

    return Ability_ShieldBoosting(RPRI.GetAbility(class'Ability_ShieldBoosting'));
}

function int GetSpiderSteroidsLevel()
{
    if(RPRI == None)
        return 0;

    return RPRI.HasAbility(class'Ability_SpiderSteroids');
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn P, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int BestDamage;

    Super.AdjustTargetDamage(Damage, OriginalDamage, P, InstigatedBy, HitLocation, Momentum, DamageType);

    // first, lets make sure we do not get countershove off a vehicle we are healing
    if ( ClassIsChildOf(DamageType,class'DamTypeLinkShaft') && P != None && Vehicle(P)!=None
        && P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)
        Momentum = vect(0,0,0);

    if(Ability == None)
    {
        Ability = GetShieldBoostingAbility();
        if(Ability == None || Ability.AbilityLevel == 0 || !Ability.bAllowed)
            return;
    }

    // We should only regen shields with the linkfire mode
    if ( !ClassIsChildOf(DamageType,class'DamTypeLinkShaft') || P == None || Vehicle(P)!=None)
        return;

    // ok, we have the linkshaft hitting someone
    BestDamage = Max(Damage, OriginalDamage);
    if (BestDamage <= 0)
        BestDamage = 10;    // if linking the damage gets set to zero

    if (P != None && BestDamage > 0)
    {
        if ( P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None )
        {
            // same team
            BoostShield(P,BestDamage);

            Momentum = vect(0,0,0);
            Damage = 0;
        }
    }
}

function RPGTick(float dt)
{
    //TODO: Find a way for ballistic weapons
    Weapon.MaxOutAmmo();
}

static function float DamageIncreasedByLinkers(int NumLinkers)
{
    if (NumLinkers <= 0)
        return 1.0;

    if (NumLinkers >= default.DamageBonusFromLinks.Length)
        return default.DamageBonusFromLinks[default.DamageBonusFromLinks.Length -1];
    else
        return default.DamageBonusFromLinks[NumLinkers];
}

static function float XPForLinker(float xpGained, int NumLinkers)
{
    local float fDamageDone;
    local float fDamageByAllLinkers;
    local float fDamagePerLinker;

    if (xpGained <= 0.0)
        return 0.0;

    // so no linkers gives 100% to turret driver
    // 1 linker is damage 175%, (7-4)/7 of xp to linker
    // 2 linkers is damage 225%, (9-4)/(9*2) = 5/18 of xp to each linker
    // 3 linkers is damage 250%, (10-4)/(10*3) = 6/30 = 1/5 to each linker
    // 4 linkers is damage 250%, (10-4)/(10*4) = 6/40 = 3/20 xp to each linker
    // 5 linkers is damage 250%, (10-4)/(10*5) = 6/50 = 3/25 xp to each linker
    fDamageDone = static.DamageIncreasedByLinkers(NumLinkers);

    fDamageByAllLinkers = fDamageDone - 1.0;    // driver always gets his 100% share
    if (fDamageByAllLinkers <= 0.0)
        return 0.0;

    fDamagePerLinker = fDamageByAllLinkers / NumLinkers;

    return (xpGained * fDamagePerLinker) / fDamageDone;

}

simulated function BuildDescription()
{
    Super.BuildDescription();
    AddToDescription(ProjectileDamageText, (class'PROJ_EngineerLinkPlasma'.default.Damage / class'LinkProjectile'.default.Damage) - 1);
    AddToDescription(ShaftDamageText, (class'EngineerLinkFire'.default.Damage / class'LinkFire'.default.Damage) - 1);
    AddToDescription(ProjectileSpeedText, (class'PROJ_EngineerLinkPlasma'.default.Speed / class'LinkProjectile'.default.Speed) - 1);
    AddToDescription(FireRateText, (class'LinkAltFire'.default.FireRate / class'EngineerLinkProjFire'.default.FireRate) - 1);
    AddToDescription(ShaftRangeText, (class'EngineerLinkFire'.default.TraceRange / class'LinkFire'.default.TraceRange) - 1);
    AddToDescription(class'WeaponModifier_Infinity'.default.InfAmmoText);
}

defaultproperties
{
     DamageBonusFromLinks(0)=1.000000
     DamageBonusFromLinks(1)=1.750000
     DamageBonusFromLinks(2)=2.250000
     DamageBonusFromLinks(3)=2.500000
     ShieldBoostingXPPercent=0.010000
     SpiderGrowthRate=1.100000
     ProjectileDamageText="$1 projectile damage"
     ShaftDamageText="$1 shaft damage/repair"
     ProjectileSpeedText="$1 projectile speed"
     FireRateText="$1 fire rate"
     ShaftRangeText="$1 shaft range"
     DamageBonus=0.000000
     ModifierOverlay=Shader'EngineerLinkShader'
     MinModifier=0
     MaxModifier=0
     PatternPos="Engineer $W of Infinity"
     bCanThrow=False
     bTeamFriendly=True
}
