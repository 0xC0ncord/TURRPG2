//=============================================================================
// FX_Blindness.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_Blindness extends RPGEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        UseRandomSubdivision=True
        Acceleration=(Z=-24.000000)
        FadeOutStartTime=0.700000
        FadeInEndTime=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=8
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=32.000000,Max=48.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'XEffects.EmitLightSmoke_t'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_Blindness.SpriteEmitter5'

}