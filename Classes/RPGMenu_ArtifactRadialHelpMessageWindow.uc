class RPGMenu_ArtifactRadialHelpMessageWindow extends FloatingWindow;

var automated AltSectionBackground sbMessage;
var automated GUIButton btOK;
var automated GUIScrollTextBox lbMessage;

var localized string WindowTitle, MessageText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    t_WindowTitle.SetCaption(WindowTitle);
    lbMessage.SetContent(MessageText);
}

function bool InternalOnClick(GUIComponent Sender)
{
    Controller.CloseMenu(false);
    return true;
}

defaultproperties
{
    WindowTitle="Artifact Radial Menu Help"
    MessageText="The Artifact Radial Menu allows you to quickly select artifacts while on the move. To use it, press and hold the artifact use key (default 'U') to bring up the radial menu. You will be presented with a cursor centered on the screen. When you move the cursor over an artifact's icon, that artifact will be selected. To close the radial menu, simply release the artifact use key, and the artifact you selected will now be your currently selected artifact.||The radial menu can be customized to your liking. To add an artifact to it, move the desired artifact from the list on the left to the list on the right. The order of the artifacts on the radial menu can also be adjusted. Additionally, you can choose to make some or all artifacts always be displayed on the radial menu even if you do not have them in your inventory. This can be useful for making sure the positioning of the artifacts on the radial menu remains consistent. Artifacts on the radial menu that are not in your inventory will be grayed out when they are displayed, and they cannot be selected."

    bResizeWidthAllowed=False
    bResizeHeightAllowed=False
    bMoveAllowed=False
    bPersistent=True
    bAllowedAsLast=True

    WinWidth=0.600000
    WinHeight=0.624722
    WinLeft=0.214063
    WinTop=0.138333

    Begin Object Class=AltSectionBackground Name=sbMessage_
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.968723
        WinHeight=0.745506
        WinLeft=0.015875
        WinTop=0.097353
        OnPreDraw=sbMessage_.InternalPreDraw
    End Object
    sbMessage=AltSectionBackground'sbMessage_'

    Begin Object Class=GUIButton Name=btOK_
        Caption="OK"
        TabOrder=0
        WinWidth=0.482870
        WinHeight=0.081551
        WinLeft=0.497916
        WinTop=0.842546
        OnClick=RPGMenu_ArtifactRadialHelpMessageWindow.InternalOnClick
        OnKeyEvent=btOK_.InternalOnKeyEvent
    End Object
    btOK=GUIButton'btOK_'

    Begin Object Class=GUIScrollTextBox Name=lbMessage_
        WinWidth=0.915046
        WinHeight=0.600470
        WinLeft=0.042592
        WinTop=0.168451
        CharDelay=0.001250
        EOLDelay=0.001250
        bNeverFocus=true
        bAcceptsInput=false
        bVisibleWhenEmpty=True
        FontScale=FNS_Small
        StyleName="NoBackground"
    End Object
    lbMessage=GUIScrollTextBox'lbMessage_'
}
