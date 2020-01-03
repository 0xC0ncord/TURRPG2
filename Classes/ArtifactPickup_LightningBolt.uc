class ArtifactPickup_LightningBolt extends RPGArtifactPickup;

defaultproperties
{
    InventoryType=Class'Artifact_LightningBolt'
    PickupMessage="You got the Lightning Bolt!"
    PickupSound=Sound'PickupSounds.SniperAmmoPickup'
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'TURRPG2.ArtifactPickupStatics.Rod'
    Skins(0)=Shader'LBolt'
    DrawScale=0.250000
    AmbientGlow=128
}
