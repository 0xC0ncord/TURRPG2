//character-specific settings
class RPGCharSettings extends Object
    config(TURRPG2Settings)
    PerObjectConfig;

struct ArtifactOrderConfigStruct
{
    var string ArtifactID;
    var bool bShowAlways;
    var bool bNeverShow;
};
var config array<ArtifactOrderConfigStruct> ArtifactOrderConfig;

struct ArtifactRadialMenuConfigStruct
{
    var string ArtifactID;
    var bool bShowAlways;
};
var config array<ArtifactRadialMenuConfigStruct> ArtifactRadialMenuConfig;

struct FavoriteWeaponStruct
{
    var class<Weapon> WeaponClass;
    var class<RPGWeaponModifier> ModifierClass;
};
var config array<FavoriteWeaponStruct> FavoriteWeaponsConfig;

defaultproperties
{
}
