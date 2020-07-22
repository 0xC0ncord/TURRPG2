//=============================================================================
// Blast_Bio.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Blast_Bio extends Blast_Projectile;

defaultproperties {
    ProjectileClass=class'PROJ_BioBombGlob'
    NumProjectiles=200
    SpeedMin=500
    SpeedMax=1250

    ChargeEmitterClass=class'FX_BlastCharger_Bio'
}
