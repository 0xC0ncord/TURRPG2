class Artifact_SphereHealing extends ArtifactBase_EffectSphere;

var int HealthPerSecond;

function ModifyEffect(RPGEffect Effect)
{
    if(Effect_Heal(Effect) != None)
    {
        Effect_Heal(Effect).HealAmount = HealthPerSecond;
    }
}

function int GetMaxHealthBonus()
{
    local Ability_LoadedMedic Ability;

    if(InstigatorRPRI != None)
    {
        Ability = Ability_LoadedMedic(InstigatorRPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
        if(Ability != None)
            return Ability.GetHealMax();
    }

    return 50;
}

defaultproperties
{
    TimerInterval=1.000000
    HealthPerSecond=15
    EffectClass=Class'Effect_Heal'
    EmitterClass=Class'FX_SphereHealing900r'
    MinAdrenaline=28
    CostPerSec=7
    bAllowInVehicle=True
    bCanBeTossed=False
    ArtifactID="SphereHealing"
    IconMaterial=Texture'SphereHealingIcon'
    ItemName="Healing Sphere"
    Description="Creates an aura that heals nearby teammates."
    HudColor=(B=192,G=64)
    bCanHaveMultipleCopies=False
}
