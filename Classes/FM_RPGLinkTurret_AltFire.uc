//=============================================================================
// FM_RPGLinkTurret_AltFire.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FM_RPGLinkTurret_AltFire extends RPGLinkFire;

var float VehicleDamageMult;

function PlayFiring()
{
    if ( LinkGun(Weapon).Links <= 0 )
        ClientPlayForceFeedback("BLinkGunBeam1");

    super(WeaponFire).PlayFiring();
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return ASVehicle(Instigator).GetFireStart();
}

simulated function bool AllowFire()
{
    return true;
}

simulated function bool myHasAmmo( LinkGun LinkGun )
{
    return true;
}

simulated function Rotator  GetPlayerAim( vector StartTrace, float InAimError )
{
    local vector HL, HN;
    ASVehicle(Instigator).CalcWeaponFire( HL, HN );
    return Rotator( HL - StartTrace );
}

simulated function float AdjustLinkDamage( LinkGun LinkGun, Actor Other, float Damage )
{
    if(LinkGun!=None)
        Damage = Damage * (LinkGun.Links+1);

    if ( Vehicle(Other)!=None )
        Damage *= VehicleDamageMult;

    return Damage;
}

simulated function ModeTick(float dt)
{
    Super(LinkFire).ModeTick(dt);
}

defaultproperties
{
     VehicleDamageMult=2.500000
     BeamEffectClass=Class'UT2k4AssaultFull.FX_LinkTurret_BeamEffect'
     DamageType=Class'UT2k4AssaultFull.DamTypeLinkTurretBeam'
     Damage=12
     TraceRange=2000.000000
     FireAnim="Fire"
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     AmmoPerFire=0
}
