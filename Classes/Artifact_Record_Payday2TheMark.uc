//=============================================================================
// Artifact_Record_Payday2TheMark.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_Record_Payday2TheMark extends ArtifactBase_Record;

defaultproperties
{
    SongName="TUR-Payday2_TheMark"
    SongArtist="Simon Viklund"
    SongTitle="The Mark"
    SongAlbum="PAYDAY 2 Official Soundtrack"
    AlbumArt=Texture'AlbumArt_Payday2'
    IconMaterial=Texture'Record_Payday2Red'
    PickupClass=Class'ArtifactPickup_Record_Payday2TheMark'
    ArtifactID="Record_Payday2TheMark"
}
