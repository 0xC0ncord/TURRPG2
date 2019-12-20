class RPGMenu_ControlBinderFakeTab extends RPGMenu_TabPage;

function ShowPanel(bool bShow)
{
    if(bShow)
        Controller.OpenMenu("TURRPG2.RPGMenu_ControlBinder");

    Super.ShowPanel(bShow);
}

function CloseMenu()
{
    RPGMenu.RPRI.Interaction.CheckBindings();
}

defaultproperties
{
    WinHeight=0.700000
}
