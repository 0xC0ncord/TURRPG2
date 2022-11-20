//=============================================================================
// Ability_MedicMotes.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_MedicMotes extends RPGAbility;

var float MoteSpawnChance;
var float DamageRequiredForSpawn;

var float DamageDealt;

var array<class<MoteBase> > MoteClasses[6];

function AdjustTargetDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Injured,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    local MoteBase Mote;

    if(
        Damage > 0
        && InstigatedBy == RPRI.Controller.Pawn
        && !class'Util'.static.SameTeamP(InstigatedBy, Injured)
    )
    {
        DamageDealt += Damage;
        if(DamageRequiredForSpawn < DamageDealt)
            DamageDealt -= DamageRequiredForSpawn;
        else
            return;

        if(FRand() > MoteSpawnChance)
            return; // big sad

        Mote = Spawn(
            MoteClasses[Rand(ArrayCount(MoteClasses))],,,
            Injured.Location + vector(RotRand() * FMin(Injured.CollisionHeight, Injured.CollisionRadius) * 0.75));
        if(Mote != None)
        {
            Mote.PlayerSpawner = InstigatedBy.Controller;
            Mote.TeamNum = InstigatedBy.GetTeamNum();
            Mote.EffectModifier += BonusPerLevel * (AbilityLevel - 1);
            PRINTD("New mote" @ Mote);
        }
    }
}

simulated function string DescriptionText()
{
    return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel));
}

defaultproperties
{
    MoteClasses(0)=Class'Mote_Ammo'
    MoteClasses(1)=Class'Mote_DamageBonus'
    MoteClasses(2)=Class'Mote_DamageReduction'
    MoteClasses(3)=Class'Mote_Shield'
    MoteClasses(4)=Class'Mote_Health'
    MoteClasses(5)=Class'Mote_Adrenaline'
    DamageRequiredForSpawn=5
    MoteSpawnChance=1.0
    BonusPerLevel=0.02
    AbilityName="Motes of the Bulwark"
    Description="Whenever you deal sufficient damage to an enemy, there is a chance that doing so will emit a mote. Motes are tiny particles packed with enormous amounts of energy that will float in the air and persist for a brief period of time. Any player that comes within range of a mote will pick it up and gain a powerful buff. These buffs can be stacked multiple times per type of mote, and any other players within range of another player having one will also receive a single instance of that buff. The motes which can be obtained are:||Mote of Ordnance (Green): grants temporary resupply|Mote of Warding (Gold): grants temporary shield regeneration|Mote of Protection (Violet): grants temporary damage reduction|Mote of Power (Red): grants a temporary damage bonus|Mote of Vitality (Blue): grants temporary health regeneration|Mote of Energy (Orange): grants temporary adrenaline regen||For every subsequent level of this ability, the buffs granted by your motes will be $1 more effective in their respective categories when applied."
    LevelCost(0)=25
    LevelCost(1)=10
    LevelCost(2)=10
    LevelCost(3)=10
    LevelCost(4)=10
    LevelCost(5)=10
    LevelCost(6)=10
    MaxLevel=7
    Category=Class'AbilityCategory_Medic'
}
