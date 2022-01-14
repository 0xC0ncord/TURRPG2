//=============================================================================
// DamTypeBurn.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeBurn extends DamageType
    abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
    DeathString="%o was fried by %k's."
    FemaleSuicide="%o set herself on fire."
    MaleSuicide="%o set himself on fire."
    bDetonatesGoop=True
    bDelayedDamage=True
    DamageOverlayMaterial=Shader'BurnedShader'
    DamageOverlayTime=0.800000
}
