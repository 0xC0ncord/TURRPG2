//=============================================================================
// ArtificerAugment_FireMode.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugmentBase_FireMode extends ArtificerAugmentBase;

struct FireModeStruct
{
    var class<Weapon> WeaponClass;
    var class<ArtificerFireModeBase> FireMode;
    var int ModeNum;
};
var array<FireModeStruct> FireModes;

var float LastPress;
var ArtificerFireModeBase FireMode;
var FireModeStruct NullEntry;

static final function FireModeStruct GetFireModeFor(class<Weapon> WeaponClass)
{
    local int i;

    for(i = 0; i < default.FireModes.Length; i++)
        if(default.FireModes[i].WeaponClass == WeaponClass)
            return default.FireModes[i];

    return default.NullEntry;
}

static function bool AllowedOn(Weapon W)
{
    local FireModeStruct Entry;

    Entry = GetFireModeFor(W.Class);
    if(Entry.WeaponClass == None)
        return false;

    return Super.AllowedOn(W);
}

function Init(WeaponModifier_Artificer WM, int NewModifierLevel)
{
    local FireModeStruct Entry;

    Super.Init(WM, NewModifierLevel);

    Entry = GetFireModeFor(Weapon.Class);
    if(Entry.WeaponClass == None)
        return;

    FireMode = WM.CreateFireMode(Entry.FireMode, Entry.ModeNum);
    if(FireMode != None)
    {
        WeaponModifier.AddFireMode(FireMode);
        FireMode.SetLevel(ModifierLevel);
        EPRINTD(PlayerController(WM.RPRI.Controller), FireMode);
    }
}

function Free()
{
    DestroyFireMode();
    Super.Free();
}

final function bool ClientStartFire(int ModeNum)
{
    if(Weapon == None || Weapon.GetFireMode(0) == None)
        return true;

    if(ModeNum == 1 && Weapon.GetFireMode(0).bIsFiring)
    {
        if(WeaponModifier.Level.TimeSeconds - LastPress > 0.5f)
        {
            WeaponModifier.NextPrimaryFireMode();
            LastPress = WeaponModifier.Level.TimeSeconds;
        }
        return false;
    }
    return true;
}

final function DestroyFireMode()
{
    EPRINTD(PlayerController(WeaponModifier.RPRI.Controller), "Destroying!");
    if(FireMode != None)
    {
        WeaponModifier.RemoveFireMode(FireMode);
        FireMode = None;
    }
}

defaultproperties
{
}
