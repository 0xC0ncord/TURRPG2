//=============================================================================
// Effect_Heal.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Heal extends RPGInstantEffect;

var int HealAmount;

var config int SelfHealingCap;
var config float SelfHealingMultiplier;

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    local RPGPlayerReplicationInfo RPRI;
    local RPGEffect Effect;
    local Ability_NullifyingCure Ability;

    if(Vehicle(Other) == None && (Other.Health >= Other.HealthMax + Modifier || Other.Health <= 0))
    {
        return false;
    }

    if(!Super.CanBeApplied(Other, Causer, Duration, Modifier))
        return false;

    // check for bleeding
    Effect = class'Effect_Bleeding'.static.GetFor(Other);
    if(Effect != None && Effect.IsInState('Activated'))
    {
        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Causer);
        if(RPRI == None)
            return false;

        // if the causer has nullifying cure, roll to see
        // if they can remove the bleeding
        Ability = Ability_NullifyingCure(RPRI.GetOwnedAbility(class'Ability_NullifyingCure'));
        if(Ability == None || FRand() > Ability.GetRemovalChance())
            return false;
        else
            Effect.Destroy();
    }

    return true;
}

function bool ShouldDisplayEffect() {
    return Vehicle(Instigator) == None;
}

function HealPassengers(Vehicle V) {
    local int x;
    local array<Pawn> Passengers;
    local Effect_Heal Heal;

    Passengers = class'Util'.static.GetAllPassengers(V);
    for(x = 0; x < Passengers.Length; x++) {
        Heal = Effect_Heal(Create(Passengers[x], EffectCauser, Duration, Modifier));
        if(Heal != None) {
            Heal.HealAmount = HealAmount;
            Heal.SelfHealingCap = SelfHealingCap;
            Heal.SelfHealingMultiplier = SelfHealingMultiplier;
            Heal.Start(); //RECURSION ALERT!
        }
    }
}

function DoEffect()
{
    local Pawn Healer;

    if(Vehicle(Instigator) != None)
    {
        HealPassengers(Vehicle(Instigator));
        return; //don't heal the vehicle itself
    }

    if(EffectCauser != None) {
        Healer = EffectCauser.Pawn;

        if(Vehicle(Healer) != None) {
            Healer = Vehicle(Healer).Driver;
        }
    }

    if(Healer == Instigator && HealAmount > SelfHealingCap)
        HealAmount = Max(1, int(float(HealAmount) * SelfHealingMultiplier));

    Instigator.GiveHealth(HealAmount, Instigator.HealthMax + Modifier);

    //Possibly grant experience
    if(
        Healer != None &&
        Healer != Instigator &&
        FriendlyMonsterController(Instigator.Controller) == None
    )
    {
        class'Util'.static.DoHealableDamage(Healer, Instigator, HealAmount);
    }
}

defaultproperties
{
    HealAmount=10
    Modifier=0 //max bonus

    SelfHealingCap=0
    SelfHealingMultiplier=1.0

    bHarmful=False
    bAllowOnEnemies=False

    EffectOverlay=Shader'TURRPG2.Overlays.PulseBlueShader'
    EffectSound=Sound'PickupSounds.HealthPack'
    EffectClass=class'FX_Heal'

    EffectMessageClass=class'EffectMessage_Heal'
}
