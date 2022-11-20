//=============================================================================
// HudCDeathmatchHelper.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class HudCDeathmatchHelper extends HudCDeathmatch
    abstract
    HideDropDown;

static final function SpriteWidget GetBarBorder(int Position)
{
    return default.BarBorder[Position];
}

static final function float GetBarBorderScaledPosition(int Position)
{
    return default.BarBorderScaledPosition[Position];
}

defaultproperties
{
}
