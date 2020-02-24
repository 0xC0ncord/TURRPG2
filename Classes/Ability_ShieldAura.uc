class Ability_ShieldAura extends AbilityBase_Aura;

function bool CanAffect(Pawn Other)
{
    return Super.CanAffect(Other) && Other.GetShieldStrength() < Other.GetShieldStrengthMax();
}

function bool ApplyEffectOn(Pawn Other)
{
    local Effect_ShieldBoost Shield;
    local FX_AuraOrb ShieldEmitter;
    local int i;

    Shield = Effect_ShieldBoost(class'Effect_ShieldBoost'.static.Create(Other, RPRI.Controller));
    if(Shield != None)
    {
        Shield.ShieldAmount = AbilityLevel * int(BonusPerLevel);
        Shield.Start();

        for(i = 0; i < Max(1, Shield.ShieldAmount / 2); i++)
        {
            ShieldEmitter = Instigator.Spawn(class'FX_AuraOrb_Shield', Instigator,, Instigator.Location, rotator(class'Util'.static.SpreadVector(Other.Location - Instigator.Location, 8000)));
            ShieldEmitter.Target = Other;
        }
    }
    return Shield != None;
}

function DoInstigatorEffects()
{
    Instigator.Spawn(class'FX_AuraPulse_Shield', Instigator,, Instigator.Location);
}

simulated function string DescriptionText()
{
    return repl(Super.DescriptionText(), "$1", class'Util'.static.FormatFloat(BonusPerLevel));
}

defaultproperties
{
    BonusPerLevel=1
    AbilityName="Safeguarding Aura"
    Description="Boosts nearby teammates' shields by $1 shield per level per second."
    StartingCost=10
    CostAddPerLevel=0
    MaxLevel=5
    RequiredAbilities(0)=(AbilityClass=Class'Ability_ShieldBoosting',Level=1)
    Category=class'AbilityCategory_Engineer'
}
