//=============================================================================
// FM_RPGLinkTurret_Fire.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FM_RPGLinkTurret_Fire extends FM_LinkTurret_Fire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local PROJ_RPGLinkTurretPlasma Proj;

    Start += Vector(Dir) * 10.0 * Weapon_RPGLinkTurret(Weapon).Links;
    Proj = Weapon.Spawn(class'PROJ_RPGLinkTurretPlasma',,, Start, Dir);
    if ( Proj != None )
    {
        Proj.Links = Weapon_RPGLinkTurret(Weapon).Links;
        Proj.LinkAdjust();
    }
    return Proj;
}

function ServerPlayFiring()
{
    if ( Weapon_RPGLinkTurret(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;

    super.ServerPlayFiring();
}

function PlayFiring()
{
    if ( Weapon_RPGLinkTurret(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;
    super.PlayFiring();
}

defaultproperties
{
     FireRate=0.400000
}
