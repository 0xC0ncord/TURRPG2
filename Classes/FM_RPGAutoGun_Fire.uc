//=============================================================================
// FM_RPGAutoGun_Fire.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FM_RPGAutoGun_Fire extends FM_Sentinel_Fire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if (Instigator.GetTeamNum() == 255)
        p = Weapon.Spawn(TeamProjectileClasses[0], Instigator, , Start, Dir);
    else
        p = Weapon.Spawn(TeamProjectileClasses[Instigator.GetTeamNum()], Instigator, , Start, Dir);
    if ( p == None )
        return None;

    p.Damage *= DamageAtten;

    return p;
}

defaultproperties
{
     TeamProjectileClasses(0)=Class'PROJ_RPGAutoGun_Laser_Red'
     TeamProjectileClasses(1)=Class'PROJ_RPGAutoGun_Laser'
     FireRate=0.450000
}
