class AbilityBase_Aura extends RPGAbility
    abstract;

var() float EffectInterval;
var() float EffectRadius;

var int NumAffected;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);
    SetTimer(EffectInterval, true);
}

function Timer()
{
    local Pawn P;

    if(Instigator == None || Instigator.Health <= 0)
        return;

    if(Instigator.DrivenVehicle != None)
        return;

    foreach Instigator.CollidingActors(class'Pawn', P, EffectRadius)
    {
        if(
            CanAffect(P) &&
            FastTrace(Instigator.Location, P.Location)
        )
        {
            if(ApplyEffectOn(P))
                NumAffected++;
        }
    }
    if(NumAffected > 0)
    {
        DoInstigatorEffects();
        NumAffected = 0;
    }
}

function bool CanAffect(Pawn Other)
{
    return (
        Other != Instigator &&
        Monster(Other) == None &&
        Vehicle(Other) == None &&
        class'Util'.static.SameTeamP(Other, Instigator));
}

function bool ApplyEffectOn(Pawn Other)
{
    return false;
}

function DoInstigatorEffects()
{
}

function PlayerDied(bool bLogout, optional Pawn Killer, optional class<DamageType> DamageType)
{
    SetTimer(0.0, false);
}

defaultproperties
{
    EffectRadius=1024.000000
    EffectInterval=1.000000
}
