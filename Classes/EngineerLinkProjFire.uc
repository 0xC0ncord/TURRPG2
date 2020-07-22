//=============================================================================
// EngineerLinkProjFire.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EngineerLinkProjFire extends LinkAltFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local PROJ_EngineerLinkPlasma Proj;

    Start += Vector(Dir) * 10.0 * LinkGun(Weapon).Links;
    Proj = Weapon.Spawn(class'PROJ_EngineerLinkPlasma',,, Start, Dir);
    if ( Proj != None )
    {
        Proj.Links = LinkGun(Weapon).Links;
        Proj.LinkAdjust();
    }
    return Proj;
}

defaultproperties
{
     FireRate=0.400000
}
