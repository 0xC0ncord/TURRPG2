class Artifact_SphereDamage extends ArtifactBase_EffectSphere;

var float KillXPPerc;
var float ExpPerDamage;

function ModifyEffect(RPGEffect Effect)
{
    if(Effect_SphereUDamage(Effect) != None)
    {
        Effect_SphereUDamage(Effect).EstimatedUDamageTime = EstimatedRunTime;
        Effect_SphereUDamage(Effect).ExpPerDamage = ExpPerDamage;
        Effect_SphereUDamage(Effect).SphereLocation = CoreLocation;
        Effect_SphereUDamage(Effect).Radius = Radius;
    }
}

function EffectRemoved(Pawn Other, RPGEffect Effect)
{
    Other.DisableUDamage();

    //Fix the annoying UDamage running out sounds
    if(xPawn(Other) != None && xPawn(Other).UDamageTimer != None)
        xPawn(Other).UDamageTimer.Destroy();
}

defaultproperties
{
     ExpPerDamage=0.000100
     EffectClass=Class'Effect_SphereUDamage'
     EmitterClass=Class'FX_SphereDamage900r'
     MinAdrenaline=40
     KillXPPerc=0.500000
     CostPerSec=10
     bAllowInVehicle=True
     bCanBeTossed=False
     IconMaterial=Texture'SphereDamageIcon'
     ItemName="Damage Sphere"
     HudColor=(B=128,G=0)
     ArtifactID="SphereDamage"
     Description="Creates an aura that grants double damage to all nearby teammates."
     bCanHaveMultipleCopies=False
}
