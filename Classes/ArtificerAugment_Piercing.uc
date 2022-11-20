//=============================================================================
// ArtificerAugment_Piercing.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Piercing extends ArtificerAugmentBase;

var class<DamageType> ModifiedDamageType;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Vehicle(Injured) != None)
        Damage += Damage * BonusPerLevel;

    if(Injured != None && Injured.GetShieldStrength() > 0 && DamageType.default.bArmorStops)
    {
        DamageType.default.bArmorStops = false;
        ModifiedDamageType = DamageType;
    }
}

function RPGTick(float dt)
{
    if(ModifiedDamageType != None)
    {
        ModifiedDamageType.default.bArmorStops = true;
        ModifiedDamageType = None;
    }
}

defaultproperties
{
    MaxLevel=1
    BonusPerLevel=0.05
    ModifierName="Piercing"
    Description="pierces shield, $1 dmg bonus against vehicles"
    LongDescription="Causes any damage done by your weapon to ignore enemy shields and adds $1 damage bonus to vehicles."
    IconMaterial=Texture'TURRPG2.WOPIcons.PiercingIcon'
    ModifierOverlay=Shader'TURRPG2.RPGWeapons.PiercingShader'
    ModifierColor=(R=128,G=196,B=255)
}

