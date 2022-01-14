//=============================================================================
// Effect_HealingDefender.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_HealingDefender extends RPGEffect;

//if we have multiple medics with this ability healing a single person who has this effect,
//instead of creating a new effect for every medic, we fill this array with the medics who
//contributed to healing in order, so that after the first medic's flames wear off, we start
//granting xp to the next and with their corresponding duration; this also prevents an xp exploit
struct MedicStruct
{
    var Pawn Medic;
    var float Modifier;
    var float Duration;
};
var array<MedicStruct> MedicQueue;

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
    return Vehicle(Instigator) == None;
}

state Activated
{
    function DisplayEffect()
    {
        local PlayerReplicationInfo CauserPRI;

        if(Level.TimeSeconds - LastEffectTime >= EffectLimitInterval)
        {
            if(EffectCauser != None)
                CauserPRI = EffectCauser.PlayerReplicationInfo;

            if(EffectMessageClass != None)
                Instigator.ReceiveLocalizedMessage(EffectMessageClass, Modifier * 2, Instigator.PlayerReplicationInfo, CauserPRI);

            if(EffectClass != None)
                SpawnedEffect = Instigator.Spawn(EffectClass, Instigator);
        }

        LastEffectTime = Level.TimeSeconds;
    }

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
                {
                    Destroy();
                }
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

                    if(MedicQueue.Length <= 0)
                    {
                        Destroy();
                        return;
                    }

                    EffectCauser = MedicQueue[0].Medic.Controller;
                    Modifier = MedicQueue[0].Modifier;
                    Duration = MedicQueue[0].Duration;
                }
            }
        }
    }
}

function AdjustPlayerDamage(
    out int Damage,
    int OriginalDamage,
    Pawn Injured,
    Pawn InstigatedBy,
    vector HitLocation,
    out vector Momentum,
    class<DamageType> DamageType
)
{
    if(
        InstigatedBy == None
        || Damage <= 0
        || InstigatedBy == Instigator
        || (
            InstigatedBy.Controller != None
            && Instigator.Controller != None
            && InstigatedBy.Controller.SameTeamAs(Instigator.Controller)
        )
    )
    {
        return;
    }

    Damage -= int(float(Damage) * Modifier * class'Ability_HealingDefender'.default.PercentPerLevel);
}

defaultproperties
{
    Modifier=0
    bHarmful=False
    TimerInterval=0.500000
    EffectClass=class'FX_HealingDefender'
    EffectMessageClass=class'EffectMessage_HealingDefender'
}
