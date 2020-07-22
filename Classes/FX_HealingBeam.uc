//=============================================================================
// FX_HealingBeam.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_HealingBeam extends FX_Beam;

defaultproperties {
    Skins(0)=FinalBlend'XEffectMat.LinkBeamBlueFB'
    LifeSpan=0.5
    LightHue=160
}
