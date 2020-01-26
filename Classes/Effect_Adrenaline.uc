class Effect_Adrenaline extends RPGInstantEffect;

var int AdrenalineAmount;

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    if(Other.Controller != None)
    {
        if(!Other.Controller.SameTeamAs(Causer))
            return false;
        if(!Other.Controller.bAdrenalineEnabled)
            return false;
        if(Other.Controller.Adrenaline >= Other.Controller.AdrenalineMax);
            return false;
    }
    else if(Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.Team != None)
    {
        if(Causer == None || Causer.GetTeamNum() != Other.PlayerReplicationInfo.Team.TeamIndex)
            return false;
    }

    return Super.CanBeApplied(Other, Causer, Duration, Modifier);
}

function bool ShouldDisplayEffect()
{
    return Vehicle(Instigator) == None;
}

function BoostPassengers(Vehicle V)
{
    local int x;
    local array<Pawn> Passengers;
    local Effect_Adrenaline Heal;

    Passengers = class'Util'.static.GetAllPassengers(V);
    for(x = 0; x < Passengers.Length; x++)
    {
        Heal = Effect_Adrenaline(Create(Passengers[x], EffectCauser, Duration, Modifier));
        if(Heal != None)
        {
            Heal.AdrenalineAmount = AdrenalineAmount;
            Heal.Start(); //RECURSION ALERT!
        }
    }
}

function DoEffect()
{
    local int AdrenGiven;
    local int CurAdren;
    local int MaxAdren;

    if(Vehicle(Instigator)!=None)
    {
        BoostPassengers(Vehicle(Instigator));
        return; //don't heal the vehicle itself
    }

    if(Instigator.Controller!=None)
    {
        CurAdren = Instigator.Controller.Adrenaline;
        MaxAdren = Instigator.Controller.AdrenalineMax;
        if (CurAdren < MaxAdren)
        {
            AdrenGiven = Min(CurAdren + AdrenalineAmount, MaxAdren);
            InstigatorRPRI.AwardAdrenaline(AdrenGiven, Self);
        }
    }
}

defaultproperties
{
     AdrenalineAmount=10
     bHarmful=False
     bAllowOnVehicles=True
     EffectSound=Sound'PickupSounds.AdrenelinPickup'
     EffectMessageClass=Class'EffectMessage_Adrenaline'
}
