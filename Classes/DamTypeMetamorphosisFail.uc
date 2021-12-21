//=============================================================================
// DamTypeMetamorphosisFail.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeMetamorphosisFail extends DamageType;

defaultproperties
{
    DeathString="%o's transformation didn't turn out quite right."
    FemaleSuicide="%o's transformation didn't turn out quite right."
    MaleSuicide="%o's transformation didn't turn out quite right."
    bAlwaysGibs=True
    bLocationalHit=False
    bAlwaysSevers=True
    GibPerterbation=1.000000
}
