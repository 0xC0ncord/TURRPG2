class Artifact_MakeMagicWeapon extends ArtifactBase_WeaponMaker;

function BotWhatNext(Bot Bot)
{
    if(
        !bActive &&
        !HasActiveArtifact(Instigator) &&
        Bot.Enemy == None &&
        Instigator.Weapon != None &&
        class'RPGWeaponModifier'.static.GetFor(Instigator.Weapon) == None && //no magic
        FRand() < 0.25
    )
    {
        Activate();
    }
}

defaultproperties
{
    bAvoidRepetition=True
    MinActivationTime=1.000000
    CostPerSec=25
    HudColor=(B=255,G=224,R=192)
    ArtifactID="MagicWeaponMaker"
    Description="Randomly enchants a weapon."
    PickupClass=Class'ArtifactPickup_MakeMagicWeapon'
    IconMaterial=Texture'TURRPG2.ArtifactIcons.MagicMaker'
    ItemName="Magic Weapon Maker"
}
