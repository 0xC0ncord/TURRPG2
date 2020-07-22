//=============================================================================
// FX_IceSmoke.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_IceSmoke extends RocketExplosion;

simulated event PostBeginPlay()
{
    local PlayerController PC;

    PC = Level.GetLocalPlayerController();
    if
    (
        PC != None &&
        (
            PC.ViewTarget == None ||
            VSize(PC.ViewTarget.Location - Location) > 5000
        )
    )
    {
        LightType = LT_None;
        bDynamicLight = false;
    }
    else
    {
        Spawn(class'RocketSmokeRing');
        if (Level.bDropDetail)
            LightRadius = 7;
    }
    //dont call super. The Super classes's postbeginplay is messed up.
}

defaultproperties
{
    LightHue=209
    LightSaturation=33
    RemoteRole=ROLE_SimulatedProxy
    DrawScale=0.000100
}
