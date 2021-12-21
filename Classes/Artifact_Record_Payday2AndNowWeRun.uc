//=============================================================================
// Artifact_Record_Payday2AndNowWeRun.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_Record_Payday2AndNowWeRun extends ArtifactBase_Record;

defaultproperties
{
    SongName="TUR-Payday2_AndNowWeRun"
    SongArtist="Simon Viklund"
    SongTitle="And Now We Run!"
    SongAlbum="PAYDAY 2 Official Soundtrack"
    AlbumArt=Texture'AlbumArt_Payday2'
    IconMaterial=Texture'Record_Payday2Blue'
    PickupClass=Class'ArtifactPickup_Record_Payday2AndNowWeRun'
    ArtifactID="Record_Payday2AndNowWeRun"
}
