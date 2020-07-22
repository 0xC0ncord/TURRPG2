class Ability_LoadedArtifacts extends RPGAbility;

defaultproperties
{
    AbilityName="Loaded Artifacts"
    Description="Grants you artifacts when you spawn."
    StartingCost=6
    CostAddPerLevel=2
    MaxLevel=4
    GrantItem(0)=(Level=1,InventoryClass=Class'Artifact_Flight')
    GrantItem(1)=(Level=1,InventoryClass=Class'Artifact_Teleport')
    GrantItem(2)=(Level=1,InventoryClass=Class'Artifact_Magnet')
    GrantItem(3)=(Level=1,InventoryClass=Class'Artifact_MakeMagicWeapon')
    GrantItem(4)=(Level=1,InventoryClass=Class'Artifact_Invulnerability')
    GrantItem(5)=(Level=2,InventoryClass=Class'Artifact_TripleDamage')
    GrantItem(6)=(Level=2,InventoryClass=Class'Artifact_MaxModifier')
    GrantItem(7)=(Level=2,InventoryClass=Class'Artifact_Fireball')
    GrantItem(8)=(Level=2,InventoryClass=Class'Artifact_RemoteDamage')
    GrantItem(9)=(Level=2,InventoryClass=Class'Artifact_RemoteInvulnerability')
    GrantItem(10)=(Level=2,InventoryClass=Class'Artifact_RemoteMax')
    GrantItem(11)=(Level=3,InventoryClass=Class'Artifact_LightningRod')
    GrantItem(12)=(Level=3,InventoryClass=Class'Artifact_DoubleModifier')
    GrantItem(13)=(Level=3,InventoryClass=Class'Artifact_PlusOneModifier')
    GrantItem(14)=(Level=3,InventoryClass=Class'Artifact_MegaBlast')
    GrantItem(15)=(Level=3,InventoryClass=Class'Artifact_PoisonBlast')
    GrantItem(16)=(Level=3,InventoryClass=Class'Artifact_FreezeBomb')
    GrantItem(17)=(Level=4,InventoryClass=Class'Artifact_LightningBolt')
    GrantItem(18)=(Level=4,InventoryClass=Class'Artifact_LightningBeam')
    GrantItem(19)=(Level=4,InventoryClass=Class'Artifact_ChainLightning')
    GrantItem(20)=(Level=4,InventoryClass=Class'Artifact_Repulsion')
    GrantItem(21)=(Level=4,InventoryClass=Class'Artifact_SphereInvulnerability')
    GrantItem(22)=(Level=4,InventoryClass=Class'Artifact_SphereDamage')
    Category=Class'AbilityCategory_Artifacts'
    IconMaterial=Texture'AbLoadedArtifactsIcon'
}
