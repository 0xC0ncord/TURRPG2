//=============================================================================
// RPGLinkSentinelBase.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGLinkSentinelBase extends ASTurret_Base;

defaultproperties
{
     StaticMesh=StaticMesh'WeaponStaticMesh.SniperAmmoPickup'
     DrawScale=1.800000
     Skins(0)=Shader'WeaponSkins.AmmoPickups.BioRifleGlassRef'
     Skins(1)=Shader'WeaponSkins.AmmoPickups.BioRifleGlassRef'
     AmbientGlow=10
     CollisionRadius=20.000000
     CollisionHeight=60.000000
}
