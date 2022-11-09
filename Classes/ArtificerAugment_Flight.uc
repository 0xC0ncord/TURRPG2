//=============================================================================
// ArtificerAugment_Flight.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Flight extends ArtificerAugmentBase;

var bool bFlightDisabled;
var FX_Flight FX;

function RPGTick(float dt)
{
    if(Instigator.Physics != PHYS_None && Instigator.Physics != PHYS_Spider)
    {
        bFlightDisabled = (Instigator.HeadVolume.KBuoyancy == 0.9999990);
        StartEffect();
    }
}

function StartEffect()
{
    if(bFlightDisabled)
    {
        StopEffect();
        return;
    }

    if(Instigator.Physics == PHYS_Flying || Instigator.Physics == PHYS_None || Instigator.Physics == PHYS_Spider)
        return;

    if(PlayerController(Instigator.Controller) != None)
    {
        if(Instigator.TouchingWaterVolume())
            Instigator.Controller.GotoState(Instigator.WaterMovementState);
        else
        {
            Instigator.Controller.GotoState('PlayerFlying');
            if(FX == None)
            {
                FX = Instigator.Spawn(class'FX_Flight', Instigator,, Instigator.Location);
                FX.SetBase(Instigator);
            }
        }
    }
}

function StopEffect()
{
    if(class'Artifact_Flight'.static.IsActiveFor(Instigator))
        return;

    if(PlayerController(Instigator.Controller) != None)
    {
        if(Instigator.TouchingWaterVolume())
            Instigator.Controller.GotoState(Instigator.WaterMovementState);
        else
            Instigator.Controller.GotoState(Instigator.LandMovementState);
    }
    if(FX != None)
    {
        FX.Kill();
        FX = None;
    }
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Instigator.Physics == PHYS_Flying)
        Momentum = (Momentum * 4f / FMin(2f, 1f + (0.25 * ModifierLevel)));
}

function Free()
{
    Super.Free();
    FX = None;
}

defaultproperties
{
    BonusPerLevel=0.02
    ModifierName="Fly"
    Description="flight"
    ModifierOverlay=TexPanner'TURRPG2.WOPWeapons.FlightPanner'
    IconMaterial=Texture'TURRPG2.WOPIcons.FlyIcon'
    ModifierColor=(R=255,G=255)
}
