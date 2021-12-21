//=============================================================================
// MorphMonster_EliteKrall.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_EliteKrall extends MorphMonster_Krall;

event PostBeginPlay()
{
    Super.PostBeginPlay();

    MyAmmo.ProjectileClass = class'EliteKrallBolt';
}

defaultproperties
{
    ScoringValue=3
    Skins(0)=FinalBlend'SkaarjPackSkins.Skins.ekrall'
    Skins(1)=FinalBlend'SkaarjPackSkins.Skins.ekrall'
}
