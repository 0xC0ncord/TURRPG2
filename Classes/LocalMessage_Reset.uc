class LocalMessage_Reset extends LocalMessage;

var(Message) localized string ResetString, SomeoneString;

static function Color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
    return class'HUD'.Default.WhiteColor;
}

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject 
    )
{
    local string Name;

    if (RelatedPRI_1 == None)
        Name = Default.SomeoneString;
    else
        Name = RelatedPRI_1.PlayerName;

    return Name @ default.ResetString;
}

defaultproperties
{
    ResetString="has reset his character!"
    SomeoneString="Someone"
    bIsSpecial=False
    DrawColor=(B=0,G=0)
}
