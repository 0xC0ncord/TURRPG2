//=============================================================================
// ArtifactBase_Record.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactBase_Record extends RPGArtifact;

var string SongName; //file name without extension
var string SongArtist; //song's artist
var string SongTitle; //song's title
var string SongAlbum; //song's album
var Material AlbumArt;

const MSG_NoJukebox = 0x0001;
var localized string MSG_Text_NoJukebox;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_NoJukebox:
            return default.MSG_Text_NoJukebox;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

function bool DoEffect()
{
    local vector V;
    local vector V2;
    local rotator R;
    local Actor A;
    local Actor_Jukebox Juke;

    if(Instigator == None || Instigator.Controller == None)
        return false;

    if(PlayerController(Instigator.Controller).bBehindView)
        PlayerController(Instigator.Controller).PlayerCalcView(A, V, R);
    else
        R = Instigator.Controller.GetViewRotation();

    Juke = Actor_Jukebox(Trace(V, V2, Instigator.Location + Instigator.EyePosition() + (vector(R) * 256), Instigator.Location + Instigator.EyePosition()));
    if(Juke == None)
    {
        if(V != vect(0, 0, 0))
            foreach RadiusActors(class'Actor_Jukebox', Juke, 64, V)
                if(Juke != None)
                    break;

        if(Juke == None)
        {
            Msg(MSG_NoJukebox);
            return false;
        }
    }

    Juke.PlaySong(Self, SongArtist, SongTitle, SongAlbum, AlbumArt);

    RemoveOne();
    return true;
}

static function string GetArtifactNameExtra()
{
    return default.Description $ "|" $ "(\"" $ default.SongTitle $ "\" by" @ default.SongArtist $ ")";
}

defaultproperties
{
    SongName=""
    SongArtist="Unknown Artist"
    SongTitle="Unknown Title"
    SongAlbum="Unknown Album"
    AlbumArt=None
    MSG_Text_NoJukebox="You must be aiming at a nearby Jukebox to use this!"
    MinActivationTime=0.000000
    PickupClass=Class'ArtifactPickup_Record'
    IconMaterial=Texture'Record_Green'
    ItemName="Music Disc"
    ArtifactID="Record"
    Description="Plays a song when put into a Jukebox."
    HudColor=(R=255,G=255,B=255)
}
