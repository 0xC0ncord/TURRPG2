//=============================================================================
// FX_PlayerLight.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_PlayerLight extends Emitter;

simulated event Tick(float dt)
{
    if (Owner == none)
    {
        Destroy();
    }
    else if (xPawn(Owner) != none)
    {
        if (xPawn(Owner).bDeRes)
            Destroy();
        else
            bHidden = xPawn(Owner).bInvis;
    }
}

simulated function LightChanged()
{
    bLightChanged = true;
}

defaultproperties
{
    AutoDestroy=True
    LightType=LT_Steady
    LightHue=180
    LightSaturation=40
    LightBrightness=255.000000
    LightRadius=15.000000
    bLightChanged=True
    bNoDelete=False
    bDynamicLight=True
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    DrawScale=50.000000
}
