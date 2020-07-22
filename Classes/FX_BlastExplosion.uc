//=============================================================================
// FX_BlastExplosion.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_BlastExplosion extends Emitter abstract;

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=False
    AutoDestroy=True
    bNoDelete=False
    Style=STY_Masked
    bDirectional=True
}
