//=============================================================================
// ArtificerFireMode_Normal.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerFireMode_Normal extends ArtificerFireModeBase;

function Initialize()
{
    FireMode = Weapon.GetFireMode(ModeNum);
    bEnabled = true;
}

function Deinitialize()
{
    if(WeaponModifier != None)
        WeaponModifier.SetFireMode(Self);
    FireMode = None;
}

defaultproperties
{
}
