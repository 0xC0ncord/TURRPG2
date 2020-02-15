class Artifact_ShieldBlast extends ArtifactBase_Blast;

defaultproperties
{
    BlastClass=class'Blast_Shield'
    BlastProjectileClass=class'BlastProjectile_Shield'
    bFriendly=True
    MaxUses=0 //infinite

    CostPerSec=25
    Cooldown=30
    HudColor=(B=0,G=255,R=255)
    ActivateSound=Sound'ShieldBlastFire'
    ArtifactID="ShieldBlast"
    Description="Boosts shields of nearby teammates."
    IconMaterial=Texture'ShieldBlastIcon'
    ItemName="Shield Blast"
    bCanBeTossed=False
}
