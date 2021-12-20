//=============================================================================
// RPGEffect.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
    Generic effect class.
    Used for Poison, Freeze, Null Entropy, etc...
*/
class RPGEffect extends Inventory
    config(TURRPG2)
    abstract;

//Immunity
var config array<class<Pawn> > ImmunePawnTypes;

//Harmful effects cannot affect teammates if friendly fire is off.
var config bool bHarmful;

//Can affect self
var config bool bAllowOnSelf;

//Can affect teammates
var config bool bAllowOnTeammates;

//Can affect enemies
var config bool bAllowOnEnemies;

//Can affect targets with god mode
var config bool bAllowOnGodMode;

//Can affect a flag carrier
var config bool bAllowOnFlagCarriers;

//Can affect manned vehicles or turrets
var config bool bAllowOnVehicles;

//Can affect monsters
var config bool bAllowOnMonsters;

//Can be prolongued if already active
var config bool bAllowStacking;

//Effect
var Controller EffectCauser;
var config float Duration;
var bool bPermanent;

var float Modifier;

var config float TimerInterval;

//Audiovisual
var Sound EffectSound;
var Material EffectOverlay;
var class<Actor> EffectClass;
var Actor SpawnedEffect;
var bool bNotifyClientKillEffect;
var bool bSpawnEffectEveryInterval;

var class<RPGEffectMessage> EffectMessageClass;
var class<RPGStatusIcon> StatusIconClass;

//Timing
var float LastStartTime;
var float LastEffectTime;
var float EffectLimitInterval; //to avoid sounds and effects being spammed like hell

//Internal
var RPGPlayerReplicationInfo InstigatorRPRI;
var bool bRestarting; //set when restarting the effect (when stacking)
var bool bClientActivated; //for clients to detect that this effect is active

replication
{
    reliable if(Role == ROLE_Authority && bNetDirty)
        Duration, EffectCauser;
    reliable if(Role == ROLE_Authority)
        ClientStart;
}

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    local GameInfo Game;
    local int i;
    local RPGPlayerReplicationInfo RPRI;
    local RPGWeaponModifier WM;
    local array<RPGArtifact> ActiveArtifacts;
    local bool bSelf, bSameTeam;

    Game = Other.Level.Game;

    //Dead
    if(Other.Health <= 0) {
        return false;
    }

    //Stacking
    if(!default.bAllowStacking && GetFor(Other) != None) {
        return false;
    }

    //Spawn Protection
    if(
        default.bHarmful &&
        Other.Level.TimeSeconds <= Other.SpawnTime + DeathMatch(Game).SpawnProtectionTime)
    {
        return false;
    }

    //Self
    bSelf = (Causer != None && Causer == Other.Controller);

    if(!default.bAllowOnSelf && bSelf) {
        return false;
    }

    bSameTeam = class'Util'.static.SameTeamCP(Causer, Other);

    //Enemies
    if(!bSameTeam) {
        if(!default.bAllowOnEnemies) {
            return false;
        }
    }

    //Teammates
    if(!bSelf && bSameTeam) {
        if(!default.bAllowOnTeammates) {
            return false;
        }

        if(default.bHarmful && TeamGame(Game) != None && TeamGame(Other.Level.Game).FriendlyFireScale == 0) {
            return false;
        }
    }

    //Invulnerability
    if(default.bHarmful && !default.bAllowOnGodMode && Other.Controller != None && Other.Controller.bGodMode)
        return false;

    //Vehicles
    if(Vehicle(Other) != None) {
        if(!default.bAllowOnVehicles) {
            return false;
        }

        if(!Vehicle(Other).bAutoTurret && Vehicle(Other).IsVehicleEmpty()) {
            return false;
        }
    }

    //Monsters
    if(!default.bAllowOnMonsters && Monster(Other) != None) {
        return false;
    }

    //Immune pawn types
    if(class'Util'.static.InArray(Other.class, default.ImmunePawnTypes) >= 0) {
        return false;
    }

    //Flag carriers
    if(
        !default.bAllowOnFlagCarriers &&
        Other.PlayerReplicationInfo != None &&
        Other.PlayerReplicationInfo.HasFlag != None
    )
    {
        return false;
    }

    //Weapon Modifier
    WM = class'RPGWeaponModifier'.static.GetFor(Other.Weapon);
    if(WM != None && !WM.AllowEffect(default.class, Causer, Duration, Modifier)) {
        return false;
    }

    //Artifacts
    ActiveArtifacts = class'RPGArtifact'.static.GetActiveArtifacts(Other);
    for(i = 0; i < ActiveArtifacts.Length; i++) {
        if(!ActiveArtifacts[i].AllowEffect(default.class, Causer, Duration, Modifier)) {
            return false;
        }
    }

    //Abilities
    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Other.Controller);
    if(RPRI != None) {
        for(i = 0; i < RPRI.Abilities.length; i++) {
            if(RPRI.Abilities[i].bAllowed) {
                if(!RPRI.Abilities[i].AllowEffect(default.class, Causer, Duration, Modifier)) {
                    return false;
                }
            }
        }
    }

    return true;
}

static function RPGEffect Create(Pawn Other, optional Controller Causer, optional float OverrideDuration, optional float NewModifier)
{
    local RPGEffect Effect;
    local RPGPlayerReplicationInfo RPRI;

    if(CanBeApplied(Other, Causer, OverrideDuration, NewModifier))
    {
        Effect = GetFor(Other);
        if(Effect != None)
        {
            Effect.bRestarting = true;

            //Update
            Effect.Stop();

            Effect.EffectCauser = Causer;

            if(OverrideDuration > 0)
                Effect.Duration = Max(Effect.Duration, OverrideDuration);

            if(NewModifier > Effect.Modifier)
                Effect.Modifier = NewModifier;

            AbilitiesModifyEffect(Effect, Other, Causer, OverrideDuration);
            CauserAbilitiesModifyEffect(Effect, Other, Causer, OverrideDuration);
        }
        else
        {
            //Create
            Effect = Other.Spawn(default.class, Other);
            Effect.GiveTo(Other);

            if(Effect != None)
            {
                Effect.EffectCauser = Causer;

                if(OverrideDuration > 0.0f)
                    Effect.Duration = OverrideDuration;

                if(NewModifier > Effect.Modifier)
                    Effect.Modifier = NewModifier;

                AbilitiesModifyEffect(Effect, Other, Causer, OverrideDuration);
                CauserAbilitiesModifyEffect(Effect, Other, Causer, OverrideDuration);

                RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Other.Controller);
                if(RPRI != None)
                {
                    Effect.InstigatorRPRI = RPRI;

                    if(Effect.StatusIconClass != None)
                        RPRI.ClientCreateStatusIcon(Effect.StatusIconClass);
                }
            }
        }
    }

    return Effect;
}

static function RemoveAll(Pawn Other)
{
    local Inventory Inv;
    local RPGEffect Effect;

    Inv = Other.Inventory;
    while(Inv != None)
    {
        Effect = RPGEffect(Inv);
        Inv = Inv.Inventory;

        if(Effect != None)
            Effect.Destroy();
    }
}

static function Remove(Pawn Other)
{
    local Inventory Inv;

    Inv = Other.FindInventoryType(default.class);
    if(Inv != None)
        Inv.Destroy();
}

static function RPGEffect GetFor(Pawn Other)
{
    local RPGEffect Effect;

    Effect = RPGEffect(Other.FindInventoryType(default.class));
    if(
        Effect != None && Effect.IsInState('Activated') ||
        (Other.Level.NetMode == NM_Client && Effect.bClientActivated)
    )
        return Effect;
    else
        return None;
}

function Start()
{
    GotoState('Activated');
    if(bRestarting)
        bRestarting = false;
    ClientStart();
}

function Stop();

simulated function ClientStart()
{
    bClientActivated = true;
}

function DisplayEffect();

function bool ShouldDisplayEffect()
{
    return true;
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
                Instigator.ReceiveLocalizedMessage(EffectMessageClass, 0, Instigator.PlayerReplicationInfo, CauserPRI);

            if(EffectClass != None && (SpawnedEffect == None || !bSpawnEffectEveryInterval))
                SpawnedEffect = Instigator.Spawn(EffectClass, Instigator);
        }

        LastEffectTime = Level.TimeSeconds;
    }

    function BeginState()
    {
        local RPGPlayerReplicationInfo RPRI;

        if(ShouldDisplayEffect())
        {
            Instigator.PlaySound(EffectSound, SLOT_Misc, 1.0,, 768);

            if(EffectOverlay != None)
                class'Sync_OverlayMaterial'.static.Sync(Instigator, EffectOverlay, Duration, false);

            DisplayEffect();
        }

        if(StatusIconClass != None) {
            RPRI = class'RPGPlayerReplicationInfo'.static.GetForPRI(Instigator.PlayerReplicationInfo);
            if(RPRI != None) {
                RPRI.ClientCreateStatusIcon(StatusIconClass);
            }
        }

        LastStartTime = Level.TimeSeconds;

        if(Duration >= TimerInterval && TimerInterval > 0)
            SetTimer(TimerInterval, true);
    }

    function Timer()
    {
        if(ShouldDisplayEffect())
            DisplayEffect();
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
                Destroy();
                return;
            }

            //re-apply overlay in case something removed it, but only if no other overlay is applied
            if(EffectOverlay != None && Instigator.OverlayMaterial == None)
                class'Sync_OverlayMaterial'.static.Sync(Instigator, EffectOverlay, Duration, false);
        }
    }

    function EndState()
    {
        local RPGPlayerReplicationInfo RPRI;
        local Controller C;

        if(StatusIconClass != None) {
            RPRI = class'RPGPlayerReplicationInfo'.static.GetForPRI(Instigator.PlayerReplicationInfo);
            if(RPRI != None) {
                RPRI.ClientRemoveStatusIcon(StatusIconClass);
            }
        }

        if(Emitter(SpawnedEffect) != None && bNotifyClientKillEffect)
        {
            if(Level.NetMode == NM_Standalone)
                Emitter(SpawnedEffect).Kill();
            else
            {
                for(C = Level.ControllerList; C != None; C = C.NextController)
                {
                    if(PlayerController(C) != None)
                    {
                        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
                        if(RPRI != None)
                            RPRI.ClientKillEmitter(Emitter(SpawnedEffect));
                    }
                }
            }
        }

        SetTimer(0, false);
    }

    function Start();

    function Stop()
    {
        GotoState('');
    }
}

static final function AbilitiesModifyEffect(RPGEffect Effect, Pawn Other, optional Controller Causer, optional float OverrideDuration)
{
    local int i;
    local RPGPlayerReplicationInfo RPRI;

    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Other.Controller);
    if(RPRI != None)
        for(i = 0; i < RPRI.Abilities.Length; i++)
            RPRI.Abilities[i].ModifyEffect(Effect, Other, Causer, OverrideDuration);
}

static final function CauserAbilitiesModifyEffect(RPGEffect Effect, Pawn Other, optional Controller Causer, optional float OverrideDuration)
{
    local int i;
    local RPGPlayerReplicationInfo RPRI;

    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Causer);
    if(RPRI != None)
        for(i = 0; i < RPRI.Abilities.Length; i++)
            RPRI.Abilities[i].ModifyEffect(Effect, Other, Causer, OverrideDuration);
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Victim, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType);
function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType);

function ModifyAdrenalineGain(out float Amount, float OriginalAmount, optional Object Source);
function ModifyAdrenalineDrain(out float Amount, float OriginalAmount, optional Object Source);

function bool OverridePickupQuery(Pawn Other, Pickup Item, out byte bAllowPickup);

defaultproperties   {
    bPermanent=False

    Duration=1.00
    TimerInterval=1.00
    EffectLimitInterval=0.50

    //by default, effects are harmful, can be stacked and allowed on anything
    bHarmful=True
    bAllowStacking=True

    bAllowOnSelf=True
    bAllowOnTeammates=True //harmful effects are still not allowed if FriendlyFireScale is 0
    bAllowOnEnemies=True
    bAllowOnGodMode=True
    bAllowOnFlagCarriers=True
    bAllowOnVehicles=True
    bAllowOnMonsters=True

    bReplicateInstigator=True
    bOnlyRelevantToOwner=True
}
