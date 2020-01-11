class RPGLabsMenu_TabPage extends MidGamePanel;

var RPGLabsMenu LabsMenu;

function InitMenu();
function CloseMenu();

event Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);
    LabsMenu = None;
}

defaultproperties
{
}
