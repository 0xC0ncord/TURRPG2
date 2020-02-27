class Artifact_FreezeBomb extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Freeze'
    BlastProjectileClass=class'BlastProjectile_Freeze'
    MaxUses=-1 //infinite

    CostPerSec=100
    HudColor=(B=255,G=224,R=224)
    ArtifactID="FreezeBomb"
    Description="Immobilizes nearby enemies."
    PickupClass=Class'ArtifactPickup_FreezeBomb'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.FreezeBomb'
    ItemName="Freeze Bomb"
    bCanBeTossed=False
}
