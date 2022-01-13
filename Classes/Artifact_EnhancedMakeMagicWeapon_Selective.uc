//=============================================================================
// Artifact_EnhancedMagicMaker_Selective.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_EnhancedMakeMagicWeapon_Selective extends Artifact_EnhancedMakeMagicWeapon;

struct SelectableModifier
{
    var string DisplayName;
    var class<RPGWeaponModifier> ModifierClass;
    var int Cost;
};
var() config array<SelectableModifier> SelectableModifiers;

var localized string SelectionTitle;
var class<RPGWeaponModifier> SelectedModifier;

var MutTURRPG RPGMut;

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
    RPGMut = class'MutTURRPG'.static.Instance(Level);
    if(RPGMut == None)
        Destroy();
}

function OnSelection(int i)
{
    CostPerSec = SelectableModifiers[i].Cost;
    SelectedModifier = SelectableModifiers[i].ModifierClass;
}

simulated function string GetSelectionTitle()
{
    return SelectionTitle;
}

simulated function int GetNumOptions()
{
    return SelectableModifiers.Length;
}

simulated function string GetOption(int i)
{
    return SelectableModifiers[i].DisplayName;
}

simulated function int GetOptionCost(int i)
{
    return SelectableModifiers[i].Cost;
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

    for(i = 0; i < SelectableModifiers.Length; i++)
        if(SelectableModifiers[i].DisplayName ~= Repl(Chosen, "_", " "))
            break;

    SelectedOption = i;
    CostPerSec = SelectableModifiers[i].Cost;
    SelectedModifier = SelectableModifiers[i].ModifierClass;
    Activate();
}

defaultproperties
{
    SelectableModifiers(0)=(DisplayName="Anti-Air",ModifierClass=Class'WeaponModifier_AntiAir',Cost=105)
    SelectableModifiers(1)=(DisplayName="Bouncy",ModifierClass=Class'WeaponModifier_Bounce',Cost=100)
    SelectableModifiers(2)=(DisplayName="Chain Lightning",ModifierClass=Class'WeaponModifier_ChainLightning',Cost=100)
    SelectableModifiers(3)=(DisplayName="Damage",ModifierClass=Class'WeaponModifier_Damage',Cost=100)
    SelectableModifiers(4)=(DisplayName="Energy",ModifierClass=Class'WeaponModifier_Energy',Cost=100)
    SelectableModifiers(5)=(DisplayName="Experience",ModifierClass=Class'WeaponModifier_Experience',Cost=100)
    SelectableModifiers(6)=(DisplayName="Feather",ModifierClass=Class'WeaponModifier_Feather',Cost=100)
    SelectableModifiers(7)=(DisplayName="Flight",ModifierClass=Class'WeaponModifier_Flight',Cost=110)
    SelectableModifiers(8)=(DisplayName="Force",ModifierClass=Class'WeaponModifier_Force',Cost=110)
    SelectableModifiers(9)=(DisplayName="Freezing",ModifierClass=Class'WeaponModifier_Freeze',Cost=110)
    SelectableModifiers(10)=(DisplayName="Infinity",ModifierClass=Class'WeaponModifier_Infinity',Cost=120)
    SelectableModifiers(11)=(DisplayName="Infinite Sturdiness",ModifierClass=Class'WeaponModifier_InfSturdy',Cost=135)
    SelectableModifiers(12)=(DisplayName="Knockback",ModifierClass=Class'WeaponModifier_Knockback',Cost=110)
    SelectableModifiers(13)=(DisplayName="Lucky",ModifierClass=Class'WeaponModifier_Luck',Cost=100)
    SelectableModifiers(14)=(DisplayName="Matrix",ModifierClass=Class'WeaponModifier_Matrix',Cost=120)
    SelectableModifiers(15)=(DisplayName="Meditation",ModifierClass=Class'WeaponModifier_Meditation',Cost=100)
    SelectableModifiers(16)=(DisplayName="Null Entropy",ModifierClass=Class'WeaponModifier_NullEntropy',Cost=120)
    SelectableModifiers(17)=(DisplayName="Penetrating",ModifierClass=Class'WeaponModifier_Penetrating',Cost=100)
    SelectableModifiers(18)=(DisplayName="Piercing",ModifierClass=Class'WeaponModifier_Meditation',Cost=110)
    SelectableModifiers(19)=(DisplayName="Poisoned",ModifierClass=Class'WeaponModifier_Poison',Cost=100)
    SelectableModifiers(20)=(DisplayName="Protection",ModifierClass=Class'WeaponModifier_Protection',Cost=100)
    SelectableModifiers(21)=(DisplayName="Quad-Shot",ModifierClass=Class'WeaponModifier_Quadshot',Cost=150)
    SelectableModifiers(22)=(DisplayName="Rage",ModifierClass=Class'WeaponModifier_Rage',Cost=130)
    SelectableModifiers(23)=(DisplayName="Sharpshooting",ModifierClass=Class'WeaponModifier_Sharpshooting',Cost=120)
    SelectableModifiers(24)=(DisplayName="Shield",ModifierClass=Class'WeaponModifier_Shield',Cost=100)
    SelectableModifiers(25)=(DisplayName="Spam",ModifierClass=Class'WeaponModifier_Spam',Cost=150)
    SelectableModifiers(26)=(DisplayName="Superfluous",ModifierClass=Class'WeaponModifier_Superfluous',Cost=120)
    SelectableModifiers(27)=(DisplayName="Vampiric",ModifierClass=Class'WeaponModifier_Vampire',Cost=110)
    SelectableModifiers(28)=(DisplayName="Vorpal",ModifierClass=Class'WeaponModifier_Vorpal',Cost=150)
    Msg_Text_NotAllowed="The chosen modifier cannot be applied this weapon."
    SelectionTitle="Pick a modifier to enhance odds of:"
    bSelection=True
    CostPerSec=0
    HudColor=(B=255,G=192,R=208)
    Description="Selectively enhance chances of receiving rare magic weapons."
}
