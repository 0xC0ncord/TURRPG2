//=============================================================================
// FX_BlastProjectile.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_BlastProjectile extends Emitter;

defaultproperties
{
    AutoDestroy=True
    bNoDelete=False
    RemoteRole=ROLE_DumbProxy
    bNetTemporary=True
    bNotOnDedServer=False
    Physics=PHYS_Trailer
}
