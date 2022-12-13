//=============================================================================
// ArtificerAugmentBase_ProjectileMod.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugmentBase_ProjectileMod extends ArtificerAugmentBase
    abstract;

const PROJ_SEARCH_RADIUS = 768;
var const int ModFlag;

var array<vector> HitLocations;

static function bool AllowedOn(WeaponModifier_Artificer WM, Weapon W)
{
    local int x;

    if(!Super.AllowedOn(WM, W))
        return false;

    for(x = 0; x < ArrayCount(W.FireModeClass); x++)
    {
        if (class<ProjectileFire>(W.FireModeClass[x]) != None)
            return true;
    }
}

static function bool CanModifyProjectile(Projectile Proj)
{
    return !bool(int(string(Proj.Tag)) & default.ModFlag);
}

function RPGTick(float dt)
{
    local Projectile Proj;

    foreach Instigator.CollidingActors(class'Projectile', Proj, PROJ_SEARCH_RADIUS)
    {
        if(Proj.Instigator != Instigator)
            continue;

        if(!default.Class.static.CanModifyProjectile(Proj))
            continue;

        ModifyProjectile(Proj);

        Proj.SetPropertyText("Tag", string(int(string(Proj.Tag)) | ModFlag));
    }
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local InstantFire WF;
    local int i;

    for(i = 0; i < 2; i++)
    {
        WF = InstantFire(Weapon.GetFireMode(i));

        if(
            WF == None
            || (
                WF.DamageType != DamageType
                && WF.GetPropertyText("DamageTypeHeadShot") != string(DamageType)
                //TODO other exotic things would go here...
            )
        )
        {
            continue;
        }

        HitLocations[HitLocations.Length] = HitLocation;
        return;
    }
}

function WeaponFire(byte Mode)
{
    local InstantFire WF;
    local array<class<Actor> > DesiredClasses;
    local Actor A;
    local int i;

    WF = InstantFire(Weapon.GetFireMode(Mode));
    if(WF == None)
        return;

    switch(Caps(string(WF.Class)))
    {
        case "XWEAPONS.ASSAULTFIRE":
        case "XWEAPONS.MINIGUNFIRE":
        case "UTCLASSIC.CLASSICSNIPERFIRE":
            DesiredClasses[DesiredClasses.Length] = class'XEffects.xHeavyWallHitEffect';
            DesiredClasses[DesiredClasses.Length] = class'XEffects.DirtImpact';
            DesiredClasses[DesiredClasses.Length] = class'XEffects.pclImpactSmoke';
            DesiredClasses[DesiredClasses.Length] = class'XEffects.pclredsmoke';
            break;
        case "XWEAPONS.SHOCKBEAMFIRE":
            DesiredClasses[DesiredClasses.Length] = class'ShockBeamEffect';
            break;
        case "XWEAPONS.MINIGUNALTFIRE":
            DesiredClasses[DesiredClasses.Length] = class'ExploWallHit';
            break;
        case "XWEAPONS.SNIPERFIRE":
            DesiredClasses[DesiredClasses.Length] = class'NewLightningBolt';
            break;
        default:
            return;
    }

    for(i = 0; i < DesiredClasses.Length; i++)
    {
        foreach Weapon.DynamicActors(DesiredClasses[i], A)
        {
            if(
                A.Instigator == Instigator
                && A.bTicked != Weapon.bTicked //just spawned
            )
            {
                switch(Caps(string(DesiredClasses[i])))
                {
                    case "XEFFECTS.XHEAVYWALLHITEFFECT":
                    case "XEFFECTS.DIRTIMPACT":
                    case "XEFFECTS.PCLIMPACTSMOKE":
                    case "XEFFECTS.PCLREDSMOKE":
                    case "XEFFECTS.EXPLOWALLHIT":
                        HitLocations[HitLocations.Length] = A.Location;
                        break;
                    case "XWEAPONS.SHOCKBEAMEFFECT":
                    case "XWEAPONS.NEWLIGHTNINGBOLT":
                        HitLocations[HitLocations.Length] = xEmitter(A).mSpawnVecA;
                        break;
                    default:
                        break;
                }
            }
        }
    }

    for(i = 0; i < HitLocations.Length; i++)
        InstantFireHit(HitLocations[i], WF);

    HitLocations.Length = 0;
}

function InstantFireHit(vector HitLocation, InstantFire FireMode);
function ModifyProjectile(Projectile P);

defaultproperties
{
}
