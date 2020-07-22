//=============================================================================
// RPGMineThrowFire.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMineThrowFire extends ONSMineThrowFire;

var string TeamProjectileClassName[4];

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    ProjectileClass = class<Projectile>(DynamicLoadObject(TeamProjectileClassName[Weapon.Instigator.GetTeamNum()], class'Class'));
    return Super.SpawnProjectile(Start, Dir);
}

defaultproperties
{
    TeamProjectileClassName(0)="Onslaught.ONSMineProjectileRED"
    TeamProjectileClassName(1)="Onslaught.ONSMineProjectileBLUE"
    TeamProjectileClassName(2)="OLTeamGames.OLTeamsONSMineProjectileGREEN"
    TeamProjectileClassName(3)="OLTeamGames.OLTeamsONSMineProjectileGOLD"
}
