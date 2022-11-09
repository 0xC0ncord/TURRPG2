//=============================================================================
// RPGMenu_ArtifactRadialHelpMessageWindow.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMenu_ArtifactRadialHelpMessageWindow extends RPGMenu_GenericPopupMessageWindow;

defaultproperties
{
    WindowTitle="Artifact Radial Menu Help"
    MessageText="The Artifact Radial Menu allows you to quickly select artifacts while on the move. To use it, press and hold the artifact use key (default 'U') to bring up the radial menu. You will be presented with a cursor centered on the screen. When you move the cursor over an artifact's icon, that artifact will be selected. To close the radial menu, simply release the artifact use key, and the artifact you selected will now be your currently selected artifact.||The radial menu can be customized to your liking. To add an artifact to it, move the desired artifact from the list on the left to the list on the right. The order of the artifacts on the radial menu can also be adjusted. Additionally, you can choose to make some or all artifacts always be displayed on the radial menu even if you do not have them in your inventory. This can be useful for making sure the positioning of the artifacts on the radial menu remains consistent. Artifacts on the radial menu that are not in your inventory will be grayed out when they are displayed, and they cannot be selected."
}
