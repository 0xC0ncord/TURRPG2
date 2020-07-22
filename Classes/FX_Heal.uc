//=============================================================================
// FX_Heal.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Heal extends RegenCrosses;

defaultproperties
{
    LifeSpan=1.00
    mStartParticles=0
    mMaxParticles=20
    mMassRange(0)=-0.5
    mMassRange(1)=-0.5
    mLifeRange(0)=1.0
    mLifeRange(1)=1.0
    Skins(0)=Texture'TURRPG2.Effects.Cross'
    mColorRange[0]=(R=171,G=208,B=254,A=255)
    mColorRange[1]=(R=171,G=208,B=254,A=255)
}
