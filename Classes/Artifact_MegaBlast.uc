class Artifact_MegaBlast extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Mega'
    BlastProjectileClass=class'BlastProjectile_Mega'
    AIHealthMin=75
    MaxUses=0 //infinite

    CostPerSec=150
    HudColor=(G=128)
    ArtifactID="MegaBlast"
    Description="Causes a big badda boom."
    PickupClass=Class'ArtifactPickup_MegaBlast'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.MegaBlast'
    ItemName="Mega Blast"
    bCanBeTossed=False
}
