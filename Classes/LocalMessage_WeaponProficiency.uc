//=============================================================================
// LocalMessage_Proficiency.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//This message is sent to the player informing them of the weapon proficiency
class LocalMessage_WeaponProficiency extends LocalMessage;

var localized string YourWeaponString;
var localized string ProficiencyMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
                optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    if(Weapon(OptionalObject) == None)
        return Repl(
                Repl(default.ProficiencyMessage, "$1", default.YourWeaponString),
                "$2", class'Util'.static.FormatPercent(Switch));
    return Repl(
            Repl(default.ProficiencyMessage, "$1", Weapon(OptionalObject).default.ItemName),
            "$2", class'Util'.static.FormatPercent(Switch));
}

defaultproperties
{
    YourWeaponString="Your weapon"
    ProficiencyMessage="$1 has a proficiency bonus of $2!"
    bIsUnique=True
    bIsConsoleMessage=False
    bFadeMessage=True
    Lifetime=2
    DrawColor=(B=128,G=32,R=32)
    PosY=0.880000
}
