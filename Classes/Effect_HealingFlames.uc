//=============================================================================
// Effect_HealingFlames.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_HealingFlames extends RPGEffect;

//if we have multiple medics with this ability healing a single person who has this effect,
//instead of creating a new effect for every medic, we fill this array with the medics who
//contributed to healing in order, so that after the first medic's flames wear off, we start
//granting xp to the next and with their corresponding duration; this also prevents an xp exploit
struct MedicStruct
{
    var Pawn Medic;
    var int MaxHeal;
    var float Duration;
};
var array<MedicStruct> MedicQueue;

var int HealAmount;
var int HealMax;

var bool bGaveHealth;

static function bool CanBeApplied(
    Pawn Other,
    optional Controller Causer,
    optional float Duration,
    optional float Modifier
)
{
    if(
        RPGBlock(Other) != None
        || RPGExplosive(Other) != None
        || Vehicle(Other) != None
        || Other.Health <= 0
    )
        return false;

    if(Other.Controller == None || !Other.Controller.SameTeamAs(Causer))
        return false;

    return Super.CanBeApplied(Other, Causer, Duration, Modifier);
}

function bool ShouldDisplayEffect()
{
    return Vehicle(Instigator) == None && bGaveHealth;
}

state Activated
{
    event Tick(float dt)
    {
        if(Instigator == None || Instigator.Health <= 0)
        {
            Destroy();
            return;
        }

        if(!bPermanent)
        {
            Duration -= dt;

            if(Duration <= 0)
            {
                if(MedicQueue.Length <= 0)
                    Destroy();
                else
                {
                    while
                    (
                        (
                            MedicQueue[0].Medic == None
                            || MedicQueue[0].Medic.Health <= 0
                            || MedicQueue[0].Medic.Controller == None
                        )
                        && MedicQueue.Length > 0
                    )
                    {
                        MedicQueue.Remove(0, 1);
                    }

                    if(MedicQueue.Length == 0)
                    {
                        Destroy();
                        return;
                    }

                    EffectCauser = MedicQueue[0].Medic.Controller;
                    Modifier = MedicQueue[0].MaxHeal;
                    Duration = MedicQueue[0].Duration;
                }
            }
        }
    }

    function Timer()
    {
        local Pawn Healer;
        local RPGPlayerReplicationInfo RPRI;
        local int AbilityLevel;

        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(EffectCauser);
        if(RPRI != None)
            AbilityLevel = RPRI.HasAbility(class'Ability_HealingDefender');

        if(EffectCauser != None)
        {
            Healer = EffectCauser.Pawn;

            if(Vehicle(Healer) != None)
                Healer = Vehicle(Healer).Driver;
        }

        bGaveHealth = false; //dont play sounds if we arent actually healing them
        bGaveHealth = Instigator.GiveHealth(HealAmount, Instigator.HealthMax + HealMax);
        if(bGaveHealth)
            Instigator.PlaySound(EffectSound, SLOT_Misc, 1.0,, 768);
        if(EffectOverlay != None)
            class'Sync_OverlayMaterial'.static.Sync(Instigator, EffectOverlay, Duration, false);
        Instigator.ReceiveLocalizedMessage(class'EffectMessage_HealingDefender', AbilityLevel);

        //Possibly grant experience
        if(
            Healer != None &&
            Healer != Instigator &&
            FriendlyMonsterController(Instigator.Controller) == None
        )
        {
            class'Util'.static.DoHealableDamage(Healer, Instigator, HealAmount);
        }

        Super.Timer();
    }
}

defaultproperties
{
    HealAmount=5
    Modifier=0
    bHarmful=False
    TimerInterval=0.5
    EffectOverlay=Shader'TURRPG2.Overlays.PulseBlueShader'
    EffectSound=Sound'PickupSounds.HealthPack'
    EffectClass=class'FX_HealingFlames'
    EffectMessageClass=class'EffectMessage_Heal'
}
