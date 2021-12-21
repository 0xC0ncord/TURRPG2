//=============================================================================
// MorphMonster_FireSkaarj.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_FireSkaarj extends MorphMonster_Skaarj;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    MyAmmo.ProjectileClass = class'FireSkaarjProjectile';
}

defaultproperties
{
    ScoringValue=7
    Skins(0)=FinalBlend'SkaarjPackSkins.Skins.Skaarjw3'
}
