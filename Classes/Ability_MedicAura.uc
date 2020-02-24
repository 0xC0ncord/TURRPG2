class Ability_MedicAura extends AbilityBase_Aura;

function bool CanAffect(Pawn Other)
{
    return Super.CanAffect(Other) && Other.Health < Other.HealthMax && Other.Health > 0;
}

function bool ApplyEffectOn(Pawn Other)
{
    local Effect_Heal Heal;
    local FX_AuraOrb HealEmitter;
    local int i;

    Heal = Effect_Heal(class'Effect_Heal'.static.Create(Other, RPRI.Controller));
    if(Heal != None)
    {
        Heal.HealAmount = AbilityLevel * int(BonusPerLevel);
        Heal.Start();

        for(i = 0; i < Max(1, Heal.HealAmount / 2); i++)
        {
            HealEmitter = Instigator.Spawn(class'FX_AuraOrb_Heal', Instigator,, Instigator.Location, rotator(class'Util'.static.SpreadVector(Other.Location - Instigator.Location, 8000)));
            HealEmitter.Target = Other;
        }
    }
    return Heal != None;
}

function DoInstigatorEffects()
{
    Instigator.Spawn(class'FX_AuraPulse_Heal', Instigator,, Instigator.Location);
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatFloat(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=1
    AbilityName="Convalescing Aura"
    Description="Heals nearby teammates by $1 health per level per second."
    StartingCost=10
    CostAddPerLevel=0
    MaxLevel=5
    RequiredAbilities(0)=(AbilityClass=Class'Ability_LoadedMedic',Level=1)
    Category=class'AbilityCategory_Medic'
}
