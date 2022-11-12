//=============================================================================
// Ability_LoadedMonsters.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_LoadedMonsters extends RPGAbility
    dependson(Artifact_ConjurerSummon)
    config(TURRPG2);

struct MonsterTypeStruct
{
    var int Level;
    var class<Monster> MonsterClass;
    var string DisplayName;
    var int Cost;
    var int Points;
    var int Cooldown;
};
var config array<MonsterTypeStruct> MonsterTypes;
var float PassiveDamageBonus, PassiveDamageReduction;

var bool bSelect;

//Client
var Interaction_ConjurerAwareness Interaction;

var localized string MonsterPreText, MonsterPostText;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientCreateInteraction;
}

simulated function ClientCreateInteraction()
{
    local PlayerController PC;

    if(Level.NetMode != NM_DedicatedServer)
    {
        if(Interaction == None)
        {
            PC = Level.GetLocalPlayerController();
            if(PC == None)
                return;

            Interaction = Interaction_ConjurerAwareness(
                PC.Player.InteractionMaster.AddInteraction(string(class'Interaction_ConjurerAwareness'), PC.Player));
        }
    }
}

function ModifyPawn(Pawn Other)
{
    local RPGArtifact A;

    Super.ModifyPawn(Other);

    ClientCreateInteraction();

    A = Artifact_ConjurerSummon(Other.FindInventoryType(class'Artifact_ConjurerSummon'));
    if(A != None)
    {
        bSelect = A == Other.SelectedItem;
        A.Destroy();
    }

    if(!bSelect)
        bSelect = Other.SelectedItem == None;

    A = Other.Spawn(class'Artifact_ConjurerSummon');
    if(A != None)
        A.GiveTo(Other);
}

simulated event Destroyed()
{
    if(Interaction != None)
    {
        Interaction.GlobalInteraction = None;
        Interaction.Master.RemoveInteraction(Interaction);
        Interaction = None;
    }

    Super.Destroyed();
}

function ModifyArtifact(RPGArtifact A)
{
    local int i;
    local Artifact_ConjurerSummon.MonsterTypeStruct ArtifactMonster;
    local Artifact_ConjurerSummon Artifact;

    if(Artifact_ConjurerSummon(A) != None)
    {
        Artifact = Artifact_ConjurerSummon(A);
        Artifact.bCanBeTossed = false;
        Artifact.MonsterTypes.Length = 0;
        for(i = 0; i < MonsterTypes.Length; i++)
        {
            if(AbilityLevel >= MonsterTypes[i].Level)
            {
                ArtifactMonster.MonsterClass = MonsterTypes[i].MonsterClass;
                ArtifactMonster.DisplayName = MonsterTypes[i].DisplayName;
                ArtifactMonster.Cost = MonsterTypes[i].Cost;
                ArtifactMonster.Points = MonsterTypes[i].Points;
                ArtifactMonster.Cooldown = MonsterTypes[i].Cooldown;

                Artifact.MonsterTypes[Artifact.MonsterTypes.Length] = ArtifactMonster;
            }
        }
        Artifact.SendMonsterTypes();

        if(bSelect)
        {
            Artifact.Instigator.SelectedItem = Artifact;
            bSelect = false;
        }
    }
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Damage > 0 && Monster(InstigatedBy) != None && FriendlyMonsterController(InstigatedBy.Controller) != None)
        Damage += float(OriginalDamage) * PassiveDamageBonus;
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Damage > 0 && Monster(Injured) != None && FriendlyMonsterController(Injured.Controller) != None)
        Damage = Max(0, Damage - float(OriginalDamage) * PassiveDamageReduction);
}

simulated function string DescriptionText()
{
    local int lv, x, i;
    local string text;
    local array<string> list;

    text = Super.DescriptionText();
    text = Repl(Repl(text, "$1", class'Util'.static.FormatPercent(PassiveDamageBonus)), "$2", class'Util'.static.FormatPercent(PassiveDamageReduction));

    text $= "|";
    for(lv = 1; lv <= MaxLevel; lv++)
    {
        list.Remove(0, list.Length);
        for(x = 0; x < MonsterTypes.Length; x++)
        {
            if(MonsterTypes[x].MonsterClass != None && MonsterTypes[x].Level == lv)
                list[list.Length] = MonsterTypes[x].DisplayName;
        }

        if(list.Length > 0)
        {
            i = 0;
            text $= "|" $ AtLevelText @ string(lv) $ MonsterPreText;
            for(x = 0; x < list.Length; x++)
            {
                i++;
                text @= list[x];

                if(x + 2 < list.Length)
                    text $= ",";
                else if(i>=2 && x + 1 < list.Length)
                    text $= ","@AndText;
                else if(x + 1 < list.Length)
                    text @= AndText;
            }
            text $= MonsterPostText;
        }
    }
    return text;
}

defaultproperties
{
    PassiveDamageBonus=0.100000
    PassiveDamageReduction=0.10000
    MonsterPreText=", you can summon the"
    MonsterPostText="."
    AbilityName="Loaded Monsters"
    Description="You are granted the Summoning Charm when you spawn.|Each level of this ability allows you to summon more powerful monsters.||Passively, your summoned monsters (regardless of the source) will receive $1 damage bonus and $2 damage reduction."
    StartingCost=1
    CostAddPerLevel=2
    MaxLevel=15
    GrantItem(0)=(Level=1,InventoryClass=Class'Artifact_KillAllMonsters')
    GrantItem(1)=(Level=1,InventoryClass=Class'Artifact_KillDesiredMonster')
    Category=Class'TURRPG2.AbilityCategory_Monsters'
    StatusIconClass=Class'TURRPG2.StatusIcon_Monsters'
    IconMaterial=Texture'AbLoadedMonstersIcon'
}
