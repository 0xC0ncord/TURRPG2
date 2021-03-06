//=============================================================================
// FX_RPGLinkSentinelBeam.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_RPGLinkSentinelBeam extends xEmitter;

defaultproperties
{
     mParticleType=PT_Beam
     mRegen=False
     mMaxParticles=3
     mLifeRange(0)=0.400000
     mLifeRange(1)=0.400000
     mRegenDist=65.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=11.000000
     mColorRange(0)=(B=240,G=240,R=240)
     mColorRange(1)=(B=240,G=240,R=240)
     mAttenuate=False
     mAttenKa=0.000000
     mWaveFrequency=0.060000
     mWaveAmplitude=8.000000
     mWaveShift=100000.000000
     mBendStrength=3.000000
     mWaveLockEnd=True
     LightType=LT_Steady
     LightHue=100
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=4.000000
     bDynamicLight=True
     bReplicateInstigator=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     Skins(0)=FinalBlend'XEffectMat.Link.LinkBeamGreenFB'
     Style=STY_Additive
}
