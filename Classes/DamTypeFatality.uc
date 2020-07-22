//=============================================================================
// DamTypeFatality.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class DamTypeFatality extends DamageType
    abstract;

defaultproperties
{
    DeathString="%o was fatalized by an admin."
    MaleSuicide="%o was fatalized by an admin."
    FemaleSuicide="%o was fatalized by an admin."

    bSuperWeapon=true
    bArmorStops=false
    bDelayedDamage=true

    bCausedByWorld=true
    bKUseOwnDeathVel=true
    KDeathVel=600
    KDeathUpKick=600

    bFlaming=true
    bAlwaysGibs=true
    GibModifier=5.0
    GibPerterbation=0.30
    bCausesBlood=true
}
