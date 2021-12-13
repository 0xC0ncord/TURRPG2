//=============================================================================
// Interaction_Jukebox.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Interaction_Jukebox extends Interaction;

var string CurrentSong;
var string CurrentSongArtist;
var string CurrentSongTitle;
var string CurrentSongAlbum;
var Material CurrentAlbumArt;
var bool bJustChanged; //if true, we should play the enter/exit animation
var bool bAnimating; //is currently animating

var float TimeAccum; //increases/decreases to 1/0 after 1 sec
var float TimeLeft; //time left to show on screen after enter animation
var float VertiPos;
var int VertiSize;
var bool bEntering, bExiting, bShowing;

function JukeboxNowPlaying(string NewSong, string SongArtist, string SongTitle, string SongAlbum, Material AlbumArt)
{
    CurrentSong = NewSong;
    CurrentSongArtist = SongArtist;
    CurrentSongTitle = SongTitle;
    CurrentSongAlbum = SongAlbum;
    CurrentAlbumArt = AlbumArt;
    bJustChanged = True;

    ViewportOwner.Actor.ReceiveLocalizedMessage(class'LocalMessage_JukeboxNowPlaying',,,, self);
}

function JukeboxDestroyed(bool bShouldRestart)
{
    CurrentSong = "";
    CurrentSongArtist = "";
    CurrentSongTitle = "";
    CurrentSongAlbum = "";
    CurrentAlbumArt = None;

    ViewportOwner.Actor.ReceiveLocalizedMessage(class'LocalMessage_JukeboxDestroyed');
    if(bShouldRestart)
        ViewportOwner.Actor.ClientSetMusic(ViewportOwner.Actor.Level.Song, MTRAN_Fade);
}

function Tick(float DeltaTime)
{
    if(!bAnimating && !bJustChanged)
        return;

    if(bEntering || bJustChanged)
    {
        if(bJustChanged)
        {
            bJustChanged = False;

            bAnimating = True;
            TimeLeft = 5.0;

            bEntering = True;
        }

        TimeAccum = FMin(TimeAccum + (DeltaTime * 4f), 1.0);
        if(TimeAccum >= 1)
        {
            bEntering = False;
            bShowing = True;
        }
    }
    else if(bShowing)
    {
        TimeLeft = FMax(TimeLeft - DeltaTime, 0.0);
        if(TimeLeft <= 0)
        {
            bShowing = False;
            bExiting = True;
        }
    }
    else if(bExiting)
    {
        TimeAccum = FMax(TimeAccum - (DeltaTime * 4f), 0.0);
        if(TimeAccum <= 0)
        {
            bExiting = False;
            bAnimating = False;
        }
    }

    if(!bShowing)
        VertiPos = (VertiSize * TimeAccum) - VertiSize;
    else
        VertiPos = 0;
}

function PostRender(Canvas Canvas)
{
    local float FontX, LFontY, FontY, EllipsesX;
    local float USize, VSize;
    local string Text;
    local array<string> Parts;

    VertiSize = Canvas.ClipY / 8;
    if (ViewportOwner.Actor.myHud.bHideHUD || !bAnimating)
        return;

    //test for font sizess
    Canvas.Font = Class'HUD_Assault'.Static.LoadFontStatic(2);
    Canvas.TextSize("A", FontX, LFontY);
    Canvas.Font = Class'HUD_Assault'.Static.LoadFontStatic(4);
    Canvas.TextSize("A", FontX, FontY);
    if(LFontY + (2 * FontY) > VertiSize)
    {
        Canvas.FontScaleY = 0.2;
        Canvas.FontScaleX = Canvas.FontScaleY;
    }
    FontY = 0; //reset for album text in case there isnt any

    Canvas.Style = 5; //alpha
    Canvas.DrawColor.R=255;
    Canvas.DrawColor.G=255;
    Canvas.DrawColor.B=255;

    //translucent black background
    Canvas.DrawColor.A = 128;
    Canvas.SetPos((Canvas.ClipX * 0.5) - (Canvas.ClipX * 0.25), VertiPos);
    Canvas.DrawTile(Texture'Engine.BlackTexture', Canvas.ClipX * 0.5, VertiSize, 0, 0, 8, 8);

    Canvas.DrawColor.A = 255;

    //song title and artist
    Canvas.SetPos((Canvas.ClipX * 0.5) - (Canvas.ClipX * 0.25) + VertiSize + (VertiSize / 6),VertiPos + (VertiSize / 12));
    Canvas.Font = Class'HUD_Assault'.Static.LoadFontStatic(2);
    Canvas.TextSize("...", EllipsesX, LFontY);
    Canvas.TextSize("A", FontX, LFontY);
    Text = "\"" $ CurrentSongTitle $ "\" by" @ CurrentSongArtist;
    Parts.Length = 0;
    Canvas.WrapStringToArray(Text, Parts, Canvas.ClipX * 0.5 - VertiSize - (VertiSize / 6) - EllipsesX);
    if(Text != Parts[0])
        Canvas.DrawTextClipped(Parts[0] $ "...");
    else
        Canvas.DrawTextClipped(Text);

    //song album
    if(CurrentSongAlbum != "")
    {
        Canvas.SetPos((Canvas.ClipX * 0.5) - (Canvas.ClipX * 0.25) + VertiSize + (VertiSize / 6), VertiPos + LFontY + (VertiSize / 12));
        Canvas.Font = Class'HUD_Assault'.Static.LoadFontStatic(4);
        Canvas.TextSize("...", EllipsesX, FontY);
        Canvas.TextSize("A", FontX, FontY);
        Text = "On \"" $ CurrentSongAlbum $ "\"";
        Parts.Length = 0;
        Canvas.WrapStringToArray(Text, Parts, Canvas.ClipX * 0.5 - VertiSize - (VertiSize / 6) - EllipsesX);
        if(Text != Parts[0])
            Canvas.DrawTextClipped(Parts[0] $ "...");
        else
            Canvas.DrawTextClipped(Text);
    }

    //song file name
    Canvas.SetPos((Canvas.ClipX * 0.5) - (Canvas.ClipX * 0.25) + VertiSize + (VertiSize / 6), VertiPos + LFontY + FontY + (VertiSize / 12));
    Canvas.Font = Class'HUD_Assault'.Static.LoadFontStatic(4);
    Canvas.TextSize("...", EllipsesX, FontY);
    Canvas.TextSize("A", FontX, FontY);
    Text = "(\"" $ CurrentSong $ ".ogg\")";
    Parts.Length = 0;
    Canvas.WrapStringToArray(Text, Parts, Canvas. ClipX * 0.5 - VertiSize - (VertiSize / 6) - EllipsesX);
    if(Text != Parts[0])
        Canvas.DrawTextClipped(Parts[0] $ "...");
    else
        Canvas.DrawTextClipped(Text);

    if(CurrentAlbumArt == None)
    {
        Canvas.SetPos((Canvas.ClipX * 0.5) - (Canvas.ClipX * 0.25), VertiPos);
        Canvas.DrawTile(Texture'NowPlaying', VertiSize, VertiSize, 0, 0, 256, 256);
        return;
    }

    //album art backdrop
    Canvas.SetPos((Canvas.ClipX * 0.5) - (Canvas.ClipX * 0.25), VertiPos);
    Canvas.DrawTile(Texture'Engine.BlackTexture', VertiSize, VertiSize, 0, 0, 8, 8);

    //album art
    USize = CurrentAlbumArt.MaterialUSize();
    VSize = CurrentAlbumArt.MaterialVSize();
    Canvas.SetPos((Canvas.ClipX * 0.5) - (Canvas.ClipX * 0.25) + (VertiSize / 24), VertiPos + (VertiSize / 24));
    Canvas.DrawTile(CurrentAlbumArt, VertiSize - (VertiSize / 12), VertiSize - (VertiSize / 12), 0, 0, USize, VSize);

    Canvas.Reset();
}

event NotifyLevelChange()
{
    Remove();
}

function Remove()
{
    Master.RemoveInteraction(self);
}

defaultproperties
{
     bVisible=True
     bRequiresTick=True
}
