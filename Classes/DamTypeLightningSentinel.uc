//=============================================================================
// DamTypeLightningSentinel.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeLightningSentinel extends VehicleDamageType
    abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth)
{
    HitEffects[0] = class'HitSmoke';
    if (Rand(25) > VictemHealth)
    HitEffects[1] = class'HitFlame';
}

defaultproperties
{
     VehicleClass=Class'RPGLightningSentinel'
     DeathString="%o was electrocuted by %k's lightning sentinel."
     FemaleSuicide="%o had an electrifying experience."
     MaleSuicide="%o had an electrifying experience."
     bCauseConvulsions=True
     bSuperWeapon=True
     bDelayedDamage=True
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
     DamageOverlayTime=1.000000
     GibPerterbation=0.250000
}
