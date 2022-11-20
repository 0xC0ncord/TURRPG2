//=============================================================================
// ArtificerAugment_Penetrating.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Penetrating extends ArtificerAugmentBase;

var int Recursions;

static function bool AllowedOn(WeaponModifier_Artificer WM, Weapon W)
{
    local ArtificerFireModeBase FireMode;
    local int i;

    if(!Super.AllowedOn(WM, W))
        return false;

    if(WM.PrimaryFireModes != None)
    {
        FireMode = WM.PrimaryFireModes;
        while(FireMode != None)
        {
            if(InstantFire(FireMode.FireMode) != None)
                return true;
            FireMode = FireMode.NextFireMode;
        }
    }

    if(WM.AlternateFireModes != None)
    {
        FireMode = WM.AlternateFireModes;
        while(FireMode != None)
        {
            if(InstantFire(FireMode.FireMode) != None)
                return true;
            FireMode = FireMode.NextFireMode;
        }
    }

    for(i = 0; i < 2; i++)
        if(InstantFire(W.GetFireMode(i)) != None)
            return true;

    return false;
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int i;
    local vector X, Y, Z, StartTrace;
    local WeaponFire FireMode;

    if(Recursions >= 10)
    {
        Log(Self @ "More than 10 recursions detected!");
        return;
    }

    for (i = 0; i < Weapon.NUM_FIRE_MODES; i++)
    {
        FireMode = Weapon.GetFireMode(i);
        if (InstantFire(FireMode) != None && InstantFire(FireMode).DamageType == DamageType)
        {
            //HACK - compensate for shock rifle not firing on crosshair
            if(ShockBeamFire(FireMode) != None && PlayerController(InstigatedBy.Controller) != None)
            {
                StartTrace = InstigatedBy.Location + InstigatedBy.EyePosition();
                Weapon.GetViewAxes(X,Y,Z);
                StartTrace = StartTrace + X * class'ShockProjFire'.Default.ProjSpawnOffset.X;
                if (!Weapon.WeaponCentered())
                    StartTrace = StartTrace + Weapon.Hand * Y * class'ShockProjFire'.Default.ProjSpawnOffset.Y + Z * class'ShockProjFire'.Default.ProjSpawnOffset.Z;

                Recursions++;
                InstantFire(FireMode).DoTrace(
                    HitLocation + Normal(HitLocation - StartTrace) * Injured.CollisionRadius * 2,
                    rotator(HitLocation - StartTrace));
                Recursions--;
            }
            else
            {
                Recursions++;
                InstantFire(FireMode).DoTrace(
                    HitLocation + Normal(HitLocation - (InstigatedBy.Location + InstigatedBy.EyePosition())) * Injured.CollisionRadius * 2,
                    rotator(HitLocation - (InstigatedBy.Location + InstigatedBy.EyePosition())));
                Recursions--;
            }
            return;
        }
    }
}

defaultproperties
{
    MaxLevel=1
    ModifierName="Penetrating"
    Description="penetrates targets"
    LongDescription="Makes instant-hit fire penetrate targets."
    IconMaterial=Texture'TURRPG2.WOPIcons.PenetratingIcon'
    ModifierOverlay=Shader'TURRPG2.RPGWeapons.PenetratingShader'
    ModifierColor=(R=64,G=64,B=255)
}


