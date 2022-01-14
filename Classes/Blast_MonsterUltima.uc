//=============================================================================
// Blast_MonsterUltima.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Blast_MonsterUltima extends Blast_Ultima;

defaultproperties
{
    Damage=150.000000
    MomentumTransfer=200000.000000
    DamageType=Class'DamTypeMonsterUltima'
    DamageStages=2
    ChargeEmitterClass=Class'FX_BlastCharger_Ultima'
    ExplosionClass=Class'FX_BlastExplosion_MonsterUltima'
    Radius=660.000000
    bBotsBeAfraid=True
    bAllowDeadInstigator=True
}
