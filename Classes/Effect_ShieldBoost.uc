class Effect_ShieldBoost extends RPGInstantEffect;

var config float ShieldBoostingXPPercent;

var int BoostingLevel;
var float ShieldBoostingPercent;
var int ShieldAmount;

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    if(RPGBlock(Other) != None || RPGExplosive(Other) != None)
        return false;
    if(Other.GetShieldStrength() >= Other.GetShieldStrengthMax())
        return false;

    if(Other.Controller != None)
    {
        if(!Other.Controller.SameTeamAs(Causer))
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
    local Effect_ShieldBoost Boost;

    Passengers = class'Util'.static.GetAllPassengers(V);
    for(x = 0; x < Passengers.Length; x++)
    {
        Boost = Effect_ShieldBoost(Create(Passengers[x], EffectCauser, Duration, Modifier));
        if(Boost != None)
        {
            Boost.ShieldAmount = ShieldAmount;
            Boost.Start(); //RECURSION ALERT!
        }
    }
}

function DoEffect()
{
    local int ShieldGiven;
    local int CurShield;
    local int MaxShield;

    if(Vehicle(Instigator)!=None)
    {
        BoostPassengers(Vehicle(Instigator));
        return; //don't heal the vehicle itself
    }

    CurShield = Instigator.GetShieldStrength();
    MaxShield = Instigator.GetShieldStrengthMax();
    if (CurShield < MaxShield)
    {
        ShieldGiven = Max(1, ShieldAmount * BoostingLevel * ShieldBoostingPercent);
        ShieldGiven = Min(MaxShield - CurShield, ShieldGiven );
        Instigator.AddShieldStrength(ShieldGiven);

        doBoosted(ShieldGiven);
    }
}

//this function does no healing. it serves to figure out the correct amount of exp to grant to the player, and grants it.
function doBoosted(int ShieldGiven)
{
    local Inv_HealableDamage Inv;
    local int ValidShieldGiven;
    local float GrantExp;
    local RPGPlayerReplicationInfo RPRI;

    if(FriendlyMonsterController(Instigator.Controller)!=None)
        return; //no exp for healing friendly pets. It's already self serving

    if(EffectCauser.Pawn!=None && Instigator == EffectCauser.Pawn)
        return; //no exp for self healing. It's already self benificial.

    Inv = Inv_HealableDamage(Instigator.FindInventoryType(class'Inv_HealableDamage'));
    if(Inv != None)
    {
        ValidShieldGiven = Min(ShieldGiven, Inv.Damage);
        if(ValidShieldGiven > 0)
        {
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(EffectCauser);
            if(RPRI == None)
                return;

            GrantExp = ShieldBoostingPercent * ShieldBoostingXPPercent * float(ValidShieldGiven);

            Inv.Damage = Max(0, Inv.Damage - ValidShieldGiven);

            class'RPGRules'.static.ShareExperience(RPRI, GrantExp);
        }

        //help keep things in check so a player never has surplus damage in storage.
        if(Inv.Damage > (Instigator.HealthMax + Class'GameRules_HealableDamage'.default.MaxHealthBonus) - Instigator.Health)
            Inv.Damage = Max(0, (Instigator.HealthMax + Class'GameRules_HealableDamage'.default.MaxHealthBonus) - Instigator.Health); //never let it go negative.
    }
}

defaultproperties
{
     ShieldBoostingXPPercent=0.010000
     ShieldAmount=10
     bHarmful=False
     bAllowOnVehicles=True
     EffectSound=Sound'PickupSounds.ShieldPack'
     EffectMessageClass=Class'EffectMessage_ShieldBoost'
}
