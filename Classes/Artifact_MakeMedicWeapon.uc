//=============================================================================
// Artifact_MakeMedicWeapon.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_MakeMedicWeapon extends ArtifactBase_WeaponMaker hidedropdown;

function RPGWeaponModifier ModifyWeapon(Weapon Weapon, class<RPGWeaponModifier> NewModifier)
{
    if(OldWeapon != None)
    {
        class'RPGWeaponModifier'.static.RemoveModifier(OldWeapon);

        if(OldWeapon.bNoAmmoInstances)
        {
            OldWeapon.AmmoCharge[0] = OldAmmo[0];
            OldWeapon.AmmoCharge[1] = OldAmmo[1];
        }
        //TODO *shrug*
        //else {}
    }

    return Super.ModifyWeapon(Weapon, NewModifier);
}

defaultproperties
{
    ModifierClass=Class'WeaponModifier_Medic'
    CostPerSec=10
    MinActivationTime=1.000000
    HudColor=(B=255,G=128,R=0)
    ArtifactID="MedicMaker"
    bCanBeTossed=False
    bAvoidRepetition=False
    Description="Generates a medic weapon."
    IconMaterial=Texture'TURRPG2.ArtifactIcons.MedicMaker'
    ItemName="Medic Weapon Maker"
}
