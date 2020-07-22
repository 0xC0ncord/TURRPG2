//=============================================================================
// StatusIcon_Ultima.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class StatusIcon_Ultima extends RPGStatusIcon;

var Ability_Ultima Ultima;

function Tick(float dt)
{
    Ultima = Ability_Ultima(RPRI.GetAbility(class'Ability_Ultima'));
    bShouldTick = (Ultima == None);
}

function bool IsVisible()
{
    return (
        Ultima != None &&
        Ultima.AbilityLevel >= 0 &&
        Ultima.KillCount > 0
    );
}

function string GetText()
{
    return "";
}

defaultproperties
{
    IconMaterial=Texture'TURRPG2.StatusIcons.Ultima'
    bShouldTick=True
}
