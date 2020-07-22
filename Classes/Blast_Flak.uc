//=============================================================================
// Blast_Flak.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Blast_Flak extends Blast_Projectile;

defaultproperties {
    ProjectileClass=class'PROJ_FlakBombShell'
    NumProjectiles=100
    SpeedMin=1000
    SpeedMax=1350

    ChargeEmitterClass=class'FX_BlastCharger_Flak'
}
