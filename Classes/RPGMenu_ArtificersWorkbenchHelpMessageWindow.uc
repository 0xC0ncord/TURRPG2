//=============================================================================
// RPGMenu_ArtificersWorkbenchHelpMessageWindow.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMenu_ArtificersWorkbenchHelpMessageWindow extends RPGMenu_GenericPopupMessageWindow;

defaultproperties
{
    WindowTitle="Artificer's Workbench Menu Help"
    MessageText="The Artificer's Workbench allows you to configure the loadouts for your Artificer's Charms. On the left is the list of Available Augments, which you receive from purchasing the Loaded Augments ability. The three lists in the center of the menu represent each of the charms you have access to. You can move augments between any of these lists as you wish in order to configure your charms. When you are finished, closing the menu will automatically update your loadouts and any charms in your inventory, as well as any weapons that were previously sealed using your charms."
}
