class LocalMessage_FavoriteWeapon extends LocalMessage;

var localized string GotFavoriteString, FavoriteWeaponString;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local string ItemName;

    if(RPGWeaponModifier(OptionalObject) != None)
        ItemName = RPGWeaponModifier(OptionalObject).Weapon.ItemName;
    else
        ItemName = default.FavoriteWeaponstring;

    return Repl(default.GotFavoriteString, "$1", ItemName);;
}

defaultproperties
{
    GotFavoriteString="You got a $1!"
    FavoriteWeaponString="favorite weapon"
    bFadeMessage=True
    bIsUnique=True
    DrawColor=(R=232,G=160,B=255,A=255)
    FontSize=0
    PosY=0.7
}
