//=============================================================================
// FX_BlastExplosion_NEW.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_BlastExplosion_NEW extends Emitter abstract;

defaultproperties
{
    AutoDestroy=True
    bNoDelete=False
    Style=STY_Masked
    RemoteRole=ROLE_DumbProxy
    bNetTemporary=True
    bDirectional=True
}
