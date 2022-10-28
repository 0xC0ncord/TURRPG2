//=============================================================================
// RPGDefenseSentinel.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGDefenseSentinel extends ASTurret
    cacheexempt;

var int ShieldHealingLevel;
var int HealthHealingLevel;
var int AdrenalineHealingLevel;
var int ResupplyLevel;
var int ArmorHealingLevel;
var float SpiderBoostLevel;
var bool bHasTransRepair;

var float HealthHealingAmount;       // the amount of health the defense sentinel heals per level (% of max health)
var float ShieldHealingAmount;       // the amount of shield the defense sentinel heals per level (% of max shield)
var float AdrenalineHealingAmount;   // the amount of adrenaline the defense sentinel heals per level (% of max adrenaline)
var float ResupplyAmount;            // the amount of resupply the defense sentinel heals per level (% of max ammo)
var float ArmorHealingAmount;        // the amount of armor the defense sentinel heals per level (% of max adrenaline)

function AddDefaultInventory()
{
    // do nothing. Do not want default weapon adding
}

defaultproperties
{
    HealthHealingAmount=1.000000
    ShieldHealingAmount=1.000000
    AdrenalineHealingAmount=1.000000
    ResupplyAmount=1.000000
    ArmorHealingAmount=1.000000
    TurretBaseClass=Class'RPGDefenseSentinelBase'
    DefaultWeaponClassName=""
    VehicleNameString="Defense Sentinel"
    bCanBeBaseForPawns=False
    bNonHumanControl=True
    Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
    DrawScale=0.500000
    AmbientGlow=10
    CollisionRadius=0.000000
    CollisionHeight=0.000000
}
