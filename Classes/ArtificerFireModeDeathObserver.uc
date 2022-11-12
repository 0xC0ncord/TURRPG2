//=============================================================================
// ArtificerFireModeDeathObserver.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerFireModeDeathObserver extends Info
    HideDropDown
    NotPlaceable;

var WeaponModifier_Artificer WeaponModifier;
var Weapon Weapon;

simulated function Setup(WeaponModifier_Artificer WM, Weapon W)
{
    WeaponModifier = WM;
    Weapon = W;
    SetBase(W); //hack to know when the weapon is destroyed
    PRINTD("Tracking" @ WM $ "," @ W);
}

simulated event BaseChange()
{
    local ArtificerFireModeBase FireMode, NextFireMode;

    PRINTD("Base change detected, new base:" @ Base);
    if(Weapon != None)
    {
        if(Base != Weapon)
        {
            if(Weapon.bPendingDelete)
            {
                PRINTD("Destroying fire modes NOW!");
                //de-init fire modes NOW!
                FireMode = WeaponModifier.PrimaryFireModes;
                while(FireMode != None)
                {
                    NextFireMode = FireMode.NextFireMode;
                    FireMode.Deinitialize();
                    FireMode.Free();
                    FireMode = NextFireMode;
                }

                FireMode = WeaponModifier.AlternateFireModes;
                while(FireMode != None)
                {
                    NextFireMode = FireMode.NextFireMode;
                    FireMode.Deinitialize();
                    FireMode.Free();
                    FireMode = NextFireMode;
                }
                Destroy();
            }
            else
                SetBase(Weapon); //ok then
        }
    }
}

defaultproperties
{
}
