class StatusIcon_Protection extends RPGStatusIcon;

function bool IsVisible() {
    return true; //controlled by Effect_Protection
}

defaultproperties {
    IconMaterial=Texture'TURRPG2.StatusIcons.Protection'
}
