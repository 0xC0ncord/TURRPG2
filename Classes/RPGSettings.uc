class RPGSettings extends Object
    config(TURRPG2Settings)
    PerObjectConfig;


var config bool bHideWeaponExtra, bHideArtifactName, bHideExpGain, bHideHints, bHideExpBar, bHideStatusIcon;
var config bool bClassicArtifactSelection;
var config int IconsPerRow;
var config float IconScale, IconsX, IconsY, IconClassicY, ExpBarX, ExpBarY;
var config float ExpGainDuration;
var config bool bEnableArtifactRadialMenu;
var config float ArtifactRadialMenuAnimSpeed;
var config float ArtifactRadialMenuMouseSens;

var config array<string> MyBuilds;

//Labs settings
var config byte XPHudStyle; //0 classic
                            //1 SAO

defaultproperties
{
    ExpGainDuration=5.000000
    ExpBarX=0.870000
    ExpBarY=0.650000
    bHideWeaponExtra=False
    bHideArtifactName=False
    bHideExpGain=False
    bHideHints=False
    bHideStatusIcon=False
    IconsPerRow=10
    IconScale=1.000000
    IconsX=0.0
    IconsY=0.20
    IconClassicY=0.666667
    bClassicArtifactSelection=False
    ArtifactRadialMenuAnimSpeed=2.000000
    ArtifactRadialMenuMouseSens=1.750000
}
