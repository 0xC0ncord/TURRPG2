//=============================================================================
// ArtificerAugment_Lucky.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Lucky extends ArtificerAugmentBase;

var float NextEffectTime;

function RPGTick(float dt)
{
    local class<Pickup> PickupClass;
    local Pickup P;
    local vector HitLocation, HitNormal, EndTrace;

    NextEffectTime -= dt;

    if(NextEffectTime > 0)
        return;

    PickupClass = ChoosePickupClass();
    EndTrace = Instigator.Location + vector(Instigator.Rotation) * Instigator.GroundSpeed;

    if(Instigator.Trace(HitLocation, HitNormal, EndTrace, Instigator.Location) != None)
    {
        HitLocation -= vector(Instigator.Rotation) * 40;
        P = Instigator.Spawn(PickupClass,,, HitLocation);
    }
    else
        P = Instigator.Spawn(PickupClass,,, EndTrace);

    if(P == None)
        return;

    if(MiniHealthPack(P) != None)
        MiniHealthPack(P).HealingAmount *= 2;
    else if(AdrenalinePickup(P) != None)
        AdrenalinePickup(P).AdrenalineAmount *= 2;

    P.RespawnTime = 0.0;
    P.bDropped = true;
    P.GotoState('Sleeping');

    GenerateNextTime();
}

function class<Pickup> ChoosePickupClass()
{
    local array<class<Pickup> > Potentials;
    local Inventory Inv;
    local Weapon W;
    local class<Pickup> AmmoPickupClass;
    local int i;

    if(Instigator.Health < Instigator.HealthMax)
    {
        Potentials[i++] = class'HealthPack';
        Potentials[i++] = class'MiniHealthPack';
    }
    else
    {
        if(Instigator.Health < Instigator.HealthMax + 100)
        {
            Potentials[i++] = class'MiniHealthPack';
            Potentials[i++] = class'MiniHealthPack';
        }
        if(Instigator.GetShieldStrength() < Instigator.GetShieldStrengthMax())
            Potentials[i++] = class'ShieldPack';
    }

    for(Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        W = Weapon(Inv);
        if(W == None)
            continue;

        if(W.NeedAmmo(0))
        {
            AmmoPickupClass = W.AmmoPickupClass(0);
            if(AmmoPickupClass != None)
                Potentials[i++] = AmmoPickupClass;
        }
        else if(W.NeedAmmo(1))
        {
            AmmoPickupClass = W.AmmoPickupClass(1);
            if(AmmoPickupClass != None)
                Potentials[i++] = AmmoPickupClass;
        }
    }

    if(FRand() < 0.05 * Modifier)
        Potentials[i++] = class'UDamagePack';

    if(i == 0 || (Instigator.Controller != None && Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax))
        Potentials[i++] = class'AdrenalinePickup';

    return Potentials[Rand(i)];
}

function StartEffect()
{
    GenerateNextTime();
}

function GenerateNextTime()
{
    NextEffectTime = float(Rand(15) + 25) / (Modifier + 1);
}

defaultproperties
{
    MaxLevel=5
    ModifierName="Lucky"
    Description="spawns pickups nearby"
    LongDescription="Spawns pickups near you. The pickups that may spawn are determined based on what resources (health, shield, ammo, etc.) you need. Higher levels of Lucky will spawn pickups more often."
    IconMaterial=Texture'TURRPG2.WOPIcons.LuckyIcon'
    ModifierOverlay=Shader'WOPWeapons.LuckyShader'
    ModifierColor=(R=255,G=128)
}
