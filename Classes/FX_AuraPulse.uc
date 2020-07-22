//=============================================================================
// FX_AuraPulse.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_AuraPulse extends Emitter;

defaultproperties
{
    AutoDestroy=True
    bNoDelete=False
    bOwnerNoSee=True
    RemoteRole=ROLE_SimulatedProxy
    bNotOnDedServer=False
    bNetTemporary=True
    bReplicateMovement=False
    Physics=PHYS_Trailer
    bTrailerAllowRotation=True
}
