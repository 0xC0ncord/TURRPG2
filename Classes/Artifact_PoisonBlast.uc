class Artifact_PoisonBlast extends ArtifactBase_Blast;

defaultproperties
{
	BlastClass=class'Blast_Poison'
	
	CostPerSec=150
	HudColor=(R=0)
	ArtifactID="PoisonBlast"
	Description="Poisons nearby enemies."
	PickupClass=Class'ArtifactPickup_PoisonBlast'
	IconMaterial=Texture'TURRPG2.ArtifactIcons.poisonblast'
	ItemName="Poison Blast"
}
