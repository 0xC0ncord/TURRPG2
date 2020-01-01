class Ability_MedicAdrenalReserve extends RPGAbility;

var bool bAdrenalineGiven;

function ModifyPawn(Pawn Other)
{
    Super.ModifyPawn(Other);

    if(!bAdrenalineGiven)
    {
        bAdrenalineGiven = true;
        RPRI.AwardAdrenaline(10, Self);
    }
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented)
{
    bAdrenalineGiven = false;

    return Super.PreventDeath(Killed, Killer, DamageType, HitLocation, bAlreadyPrevented);
}

defaultproperties
{
    AbilityName="Medic Adrenal Reserve"
    Description="Allows you to start with 10 adrenaline when you spawn so that you can roll your Medic weapon immediately."
    StartingCost=10
    MaxLevel=1
    Category=Class'AbilityCategory_Medic'
}
