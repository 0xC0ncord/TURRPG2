class Blast_Heal extends Blast;

var config float MinHealing, MaxHealing;
var float EXPMultiplier;

function DoEffect()
{
    local float healingScale, dist;
    local vector dir;
    local Controller C;
    local Pawn P;
    local int MaxHealth;
    local int HealthGiven;
    local Effect_Heal Heal;

    if (Instigator == None && InstigatorController != None)
        Instigator = InstigatorController.Pawn;

    MaxHealth = GetMaxHealthBonus();

    if(Instigator != None)
    {
        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(
                C.Pawn != None &&
                C.Pawn.Health > 0 &&
                VSize(C.Pawn.Location - Location) <= Radius &&
                FastTrace(C.Pawn.Location, Location)
            )
            {
                P = C.Pawn;

                if(bAffectInstigator || P != Instigator)
                {
                    //heal them
                    dir = C.Pawn.Location - Location;
                    dist = FMax(1,VSize(dir));
                    healingScale = 1 - FMax(0,dist/Radius);

                    HealthGiven = max(1, (healingScale * (MaxHealing-MinHealing)) + MinHealing);
                    if(HealthGiven > 0)
                    {
                        Heal = Effect_Heal(class'Effect_Heal'.static.Create(P, Instigator.Controller,, MaxHealth));
                        if(Heal != None)
                        {
                            Heal.HealAmount = HealthGiven;
                            Heal.Start();
                        }
                        //class'GameRules_HealableDamage'.static.Heal(P, HealthGiven, Instigator, localMaxHealth, EXPMultiplier, true);
                    }
                }
            }
        }
    }

    Destroy();
}

function int GetMaxHealthBonus()
{
    local Ability_LoadedMedic Ability;
    local RPGPlayerReplicationInfo RPRI;

    if(Instigator != None)
    {
        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Instigator.Controller);
        if(RPRI != None)
        {
            Ability = Ability_LoadedMedic(RPRI.GetOwnedAbility(class'Ability_LoadedMedic'));
            if(Ability != None)
                return Ability.GetHealMax();
        }
    }
    return 50;
}

defaultproperties
{
    bAffectInstigator=True
    bBotsBeAfraid=False
    ChargeTime=2.000000
    MaxHealing=250.000000
    MinHealing=50.000000
    Radius=2200.000000
    ChargeEmitterClass=class'FX_BlastCharger_Heal_NEW'
    ExplosionClass=class'FX_BlastExplosion_Heal_NEW'
}
