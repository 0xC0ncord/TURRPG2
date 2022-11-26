//=============================================================================
// Artifact_EnhancedMagicMaker_Selective.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EnhancedMakeMagicWeapon_Selective extends Artifact_EnhancedMakeMagicWeapon;

struct ModifierCostStruct
{
    var class<RPGWeaponModifier> ModifierClass;
    var int Cost;
};
var() array<ModifierCostStruct> ModifierCosts;
var int DefaultCostPerSec;

struct AvailableModifierStruct
{
    var string DisplayName;
    var class<RPGWeaponModifier> ModifierClass;
    var int Cost;
};
var array<AvailableModifierStruct> AvailableModifiers;

var localized string SelectionTitle;
var class<RPGWeaponModifier> SelectedModifier;

var MutTURRPG RPGMut;
var RPGReplicationInfo RRI;

const MSG_NotAllowed = 0x0103;
var localized string Msg_Text_NotAllowed;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_NotAllowed:
            return default.Msg_Text_NotAllowed;
        default:
            return Super.GetMessageString(Msg, Value);
    }
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if(Role == ROLE_Authority)
    {
        RPGMut = class'MutTURRPG'.static.Instance(Level);
        if(RPGMut == None)
            Destroy();
    }
}

simulated function PostNetBeginPlay()
{
    local int i, x, y;

    Super.PostNetBeginPlay();

    RRI = class'RPGReplicationInfo'.static.Get(Level);
    if(RRI != None)
    {
        for(i = 0; i < RRI.MAX_WEAPONMODIFIERS; i++)
        {
            if(RRI.WeaponModifiers[i] == None)
                break;

            x = AvailableModifiers.Length;
            AvailableModifiers.Length = x + 1;
            AvailableModifiers[x].ModifierClass = RRI.WeaponModifiers[i];
            AvailableModifiers[x].DisplayName =
                class'Util'.static.Trim(Repl(Repl(RRI.WeaponModifiers[i].default.PatternPos, "$W", ""), "of", ""));

            for(y = 0; y < ModifierCosts.Length; y++)
            {
                if(ModifierCosts[y].ModifierClass == AvailableModifiers[x].ModifierClass)
                {
                    AvailableModifiers[x].Cost = ModifierCosts[y].Cost;
                    break;
                }
            }
            if(AvailableModifiers[x].Cost == 0)
                AvailableModifiers[x].Cost = DefaultCostPerSec;
        }
    }
}

function OnSelection(int i)
{
    SelectedModifier = AvailableModifiers[i].ModifierClass;
    CostPerSec = AvailableModifiers[i].Cost;
}

simulated function string GetSelectionTitle()
{
    return SelectionTitle;
}

simulated function int GetNumOptions()
{
    return AvailableModifiers.Length;
}

simulated function string GetOption(int i)
{
    return AvailableModifiers[i].DisplayName;
}

simulated function int GetOptionCost(int i)
{
    return AvailableModifiers[i].Cost;
}

function bool CanActivate()
{
    if(SelectedOption < 0)
        CostPerSec = 0; //no cost until selection

    if(!Super.CanActivate())
        return false;

    return true;
}

function bool CheckSelection()
{
    if(!Super.CheckSelection())
        return false;
    if(SelectedModifier == None || !SelectedModifier.static.AllowedFor(Instigator.Weapon.Class, Instigator))
    {
        Msg(MSG_NotAllowed);
        SelectedOption = -1;
        return false;
    }
    return true;
}

function class<RPGWeaponModifier> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other)
{
    local int x, Chance, Tries;
    local int AddedChance;

    if(RPGMut.WeaponModifiers.Length == 0)
        return None;

    for(x = 0; x < RPGMut.WeaponModifiers.Length; x++)
    {
        if(RPGMut.WeaponModifiers[x].ModifierClass == SelectedModifier)
        {
            AddedChance = Max(1, Ceil(float(RPGMut.WeaponModifiers[x].Chance) * RPGMut.TotalModifierChance * 0.1f));
            break;
        }
    }

    while(Tries < 10)
    {
        Tries++;

        Chance = Rand(RPGMut.TotalModifierChance);
        for (x = 0; x < RPGMut.WeaponModifiers.Length; x++)
        {
            if(RPGMut.WeaponModifiers[x].ModifierClass == SelectedModifier)
                Chance -= RPGMut.WeaponModifiers[x].Chance + AddedChance;
            else
                Chance -= RPGMut.WeaponModifiers[x].Chance;
            if (Chance < 0)
            {
                if(RPGMut.WeaponModifiers[x].ModifierClass.static.AllowedFor(WeaponType, Other))
                    return RPGMut.WeaponModifiers[x].ModifierClass;
                break;
            }
        }
    }
    return None;
}

exec function Gen(string Chosen)
{
    local int i;

    for(i = 0; i < AvailableModifiers.Length; i++)
        if(AvailableModifiers[i].DisplayName ~= Repl(Chosen, "_", " "))
            break;

    SelectedOption = i;
    SelectedModifier = AvailableModifiers[i].ModifierClass;
    CostPerSec = AvailableModifiers[i].Cost;
    Activate();
}

defaultproperties
{
    ModifierCosts(0)=(ModifierClass=Class'WeaponModifier_AntiAir',Cost=105)
    ModifierCosts(1)=(ModifierClass=Class'WeaponModifier_Bounce',Cost=100)
    ModifierCosts(2)=(ModifierClass=Class'WeaponModifier_ChainLightning',Cost=100)
    ModifierCosts(3)=(ModifierClass=Class'WeaponModifier_Damage',Cost=100)
    ModifierCosts(4)=(ModifierClass=Class'WeaponModifier_Energy',Cost=100)
    ModifierCosts(5)=(ModifierClass=Class'WeaponModifier_Experience',Cost=100)
    ModifierCosts(6)=(ModifierClass=Class'WeaponModifier_Feather',Cost=100)
    ModifierCosts(7)=(ModifierClass=Class'WeaponModifier_Flight',Cost=110)
    ModifierCosts(8)=(ModifierClass=Class'WeaponModifier_Force',Cost=110)
    ModifierCosts(9)=(ModifierClass=Class'WeaponModifier_Freeze',Cost=110)
    ModifierCosts(10)=(ModifierClass=Class'WeaponModifier_Infinity',Cost=120)
    ModifierCosts(11)=(ModifierClass=Class'WeaponModifier_InfSturdy',Cost=135)
    ModifierCosts(12)=(ModifierClass=Class'WeaponModifier_Knockback',Cost=110)
    ModifierCosts(13)=(ModifierClass=Class'WeaponModifier_Luck',Cost=100)
    ModifierCosts(14)=(ModifierClass=Class'WeaponModifier_Matrix',Cost=120)
    ModifierCosts(15)=(ModifierClass=Class'WeaponModifier_Meditation',Cost=100)
    ModifierCosts(16)=(ModifierClass=Class'WeaponModifier_NullEntropy',Cost=120)
    ModifierCosts(17)=(ModifierClass=Class'WeaponModifier_Penetrating',Cost=100)
    ModifierCosts(18)=(ModifierClass=Class'WeaponModifier_Meditation',Cost=110)
    ModifierCosts(19)=(ModifierClass=Class'WeaponModifier_Poison',Cost=100)
    ModifierCosts(20)=(ModifierClass=Class'WeaponModifier_Protection',Cost=100)
    ModifierCosts(21)=(ModifierClass=Class'WeaponModifier_Quadshot',Cost=150)
    ModifierCosts(22)=(ModifierClass=Class'WeaponModifier_Rage',Cost=130)
    ModifierCosts(23)=(ModifierClass=Class'WeaponModifier_Sharpshooting',Cost=120)
    ModifierCosts(24)=(ModifierClass=Class'WeaponModifier_Shield',Cost=100)
    ModifierCosts(25)=(ModifierClass=Class'WeaponModifier_Spam',Cost=150)
    ModifierCosts(26)=(ModifierClass=Class'WeaponModifier_Superfluous',Cost=120)
    ModifierCosts(27)=(ModifierClass=Class'WeaponModifier_Vampire',Cost=110)
    ModifierCosts(28)=(ModifierClass=Class'WeaponModifier_Vorpal',Cost=150)
    DefaultCostPerSec=100
    Msg_Text_NotAllowed="The chosen modifier cannot be applied this weapon."
    SelectionTitle="Pick a modifier to enhance odds of:"
    bSelection=True
    CostPerSec=0
    HudColor=(B=255,G=192,R=208)
    Description="Selectively enhance chances of receiving rare magic weapons."
}
