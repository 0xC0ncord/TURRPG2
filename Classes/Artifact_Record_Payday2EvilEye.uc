//=============================================================================
// Artifact_Record_Payday2EvilEye.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_Record_Payday2EvilEye extends ArtifactBase_Record;

defaultproperties
{
    SongName="TUR-Payday2_EvilEye"
    SongArtist="Simon Viklund"
    SongTitle="Evil Eye"
    SongAlbum="PAYDAY 2 Official Soundtrack"
    AlbumArt=Texture'AlbumArt_Payday2'
    IconMaterial=Texture'Record_Payday2Magenta'
    PickupClass=Class'ArtifactPickup_Record_Payday2EvilEye'
    ArtifactID="Record_Payday2EvilEye"
}
