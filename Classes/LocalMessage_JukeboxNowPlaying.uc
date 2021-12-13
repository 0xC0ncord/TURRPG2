//=============================================================================
// LocalMessage_JukeboxNowPlaying.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_JukeboxNowPlaying extends CriticalEventPlus;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    if(Interaction_Jukebox(OptionalObject) == None)
        return "";

    if(Interaction_Jukebox(OptionalObject).CurrentSongAlbum != "")
        return "Now playing: \"" $ Interaction_Jukebox(OptionalObject).CurrentSongTitle $ "\" by" @ Interaction_Jukebox(OptionalObject).CurrentSongArtist @ "on \"" $ Interaction_Jukebox(OptionalObject).CurrentSongAlbum $ "\" (\"" $ Interaction_Jukebox(OptionalObject).CurrentSong $ "\")";
    return "Now playing: \"" $ Interaction_Jukebox(OptionalObject).CurrentSongTitle $ "\" by" @ Interaction_Jukebox(OptionalObject).CurrentSongArtist @ "(\"" $ Interaction_Jukebox(OptionalObject).CurrentSong $ "\")";
}

defaultproperties
{
    Lifetime=0
    DrawColor=(A=0)
}
