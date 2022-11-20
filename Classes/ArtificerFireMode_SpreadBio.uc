//=============================================================================
// ArtificerFireMode_SpreadBio.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerFireMode_SpreadBio extends ArtificerFireModeBase;

function Activate()
{
    WeaponFire_SpreadBio(FireMode).StartSpread();
}

function SetLevel(int NewModifier)
{
    Super.SetLevel(NewModifier);
    WeaponFire_SpreadBio(FireMode).SetLevel(NewModifier);
}

defaultproperties
{
    FireModeClass=Class'WeaponFire_SpreadBio'
}
