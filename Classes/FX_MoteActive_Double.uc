//=============================================================================
// FX_MoteActive_Double.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_MoteActive_Double extends FX_MoteActive;

simulated function Tick(float dt)
{
    Emitters[1].StartLocationOffset = Location;
    Emitters[2].StartLocationOffset = Location;
    Emitters[3].StartLocationOffset = Location;
    Emitters[5].StartLocationOffset = Location;
    Emitters[6].StartLocationOffset = Location;
    Emitters[7].StartLocationOffset = Location;
}

defaultproperties
{
}
